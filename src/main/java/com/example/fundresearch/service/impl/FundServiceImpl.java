package com.example.fundresearch.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.fundresearch.dto.*;
import com.example.fundresearch.entity.*;
import com.example.fundresearch.mapper.*;
import com.example.fundresearch.service.FundService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class FundServiceImpl implements FundService {

    private static final Logger log = LoggerFactory.getLogger(FundServiceImpl.class);
    private static final int PAGE_SIZE = 20;

    @Autowired private FundMapper fundMapper;
    @Autowired private FundNavMapper fundNavMapper;
    @Autowired private FundCompanyMapper fundCompanyMapper;
    @Autowired private FundManagerMapper fundManagerMapper;
    @Autowired private TagMapper tagMapper;
    @Autowired private FundTagRelationMapper fundTagRelationMapper;
    @Autowired private PortfolioMapper portfolioMapper;
    @Autowired private PortfolioItemMapper portfolioItemMapper;
    @Autowired private UserMapper userMapper;
    @Autowired private FundAnnouncementMapper fundAnnouncementMapper;
    @Autowired private FundSectorMapper fundSectorMapper;
    @Autowired private FundStockMapper fundStockMapper;

    private final RestTemplate restTemplate = new RestTemplate();

    // ==================== 基金查询 ====================
    @Override
    @Transactional(readOnly = true)
    public Page<FundListDTO> searchFunds(String keyword, String type, String riskLevel,
                                         List<Long> tagIds, int page, int size) {
        if (size <= 0 || size > 100) size = PAGE_SIZE;
        int mpPage = page + 1;
        LambdaQueryWrapper<Fund> wrapper = Wrappers.lambdaQuery();
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(Fund::getName, keyword).or().like(Fund::getCode, keyword));
        }
        if (type != null && !type.isEmpty()) {
            wrapper.eq(Fund::getType, type);
        }
        if (riskLevel != null && !riskLevel.isEmpty()) {
            wrapper.eq(Fund::getRiskLevel, riskLevel);
        }
        if (tagIds != null && !tagIds.isEmpty()) {
            List<Tag> selectedTags = tagMapper.selectBatchIds(tagIds);
            boolean sameDimension = true;
            if (!selectedTags.isEmpty()) {
                String firstDim = selectedTags.get(0).getDimension();
                for (Tag t : selectedTags) {
                    if (!t.getDimension().equals(firstDim)) {
                        sameDimension = false;
                        break;
                    }
                }
            }
            List<Long> fundIds;
            if (sameDimension) {
                fundIds = fundTagRelationMapper.selectList(
                        new LambdaQueryWrapper<FundTagRelation>()
                                .in(FundTagRelation::getTagId, tagIds)
                                .select(FundTagRelation::getFundId)
                ).stream().map(FundTagRelation::getFundId).distinct().collect(Collectors.toList());
            } else {
                fundIds = fundTagRelationMapper.findFundIdsByAllTags(tagIds, tagIds.size());
            }
            if (fundIds.isEmpty()) {
                return new Page<>(mpPage, size, 0);
            }
            wrapper.in(Fund::getId, fundIds);
        }
        Page<Fund> fundPage = fundMapper.selectPage(new Page<>(mpPage, size), wrapper);
        Page<FundListDTO> dtoPage = new Page<>(fundPage.getCurrent(), fundPage.getSize(), fundPage.getTotal());
        dtoPage.setRecords(fundPage.getRecords().stream().map(this::toFundListDTO).collect(Collectors.toList()));
        return dtoPage;
    }

    private FundListDTO toFundListDTO(Fund fund) {
        FundListDTO dto = new FundListDTO();
        dto.setId(fund.getId());
        dto.setCode(fund.getCode());
        dto.setName(fund.getName());
        dto.setType(fund.getType());
        dto.setRiskLevel(fund.getRiskLevel());
        LambdaQueryWrapper<FundNav> navWrapper = Wrappers.lambdaQuery();
        navWrapper.eq(FundNav::getFundId, fund.getId())
                  .orderByDesc(FundNav::getDate)
                  .last("LIMIT 1");
        FundNav latestNav = fundNavMapper.selectOne(navWrapper);
        if (latestNav != null) {
            dto.setUnitNav(latestNav.getUnitNav());
            dto.setDailyReturn(latestNav.getDailyReturn());
        }
        return dto;
    }

    // ==================== 基金画像 ====================
    @Override
    @Transactional(readOnly = true)
    public FundProfileDTO getFundProfile(Long fundId) {
        Fund fund = fundMapper.selectById(fundId);
        if (fund == null) throw new RuntimeException("基金不存在");
        FundProfileDTO dto = new FundProfileDTO();
        dto.setId(fund.getId()); dto.setCode(fund.getCode()); dto.setName(fund.getName());
        dto.setType(fund.getType()); dto.setScale(fund.getScale());
        dto.setEstablishDate(fund.getEstablishDate()); dto.setRiskLevel(fund.getRiskLevel());
        dto.setBenchmark(fund.getBenchmark()); dto.setAttributionText(fund.getAttributionText());
        if (fund.getCompanyId() != null) {
            FundCompany c = fundCompanyMapper.selectById(fund.getCompanyId());
            if (c != null) dto.setCompanyName(c.getName());
        }
        if (fund.getManagerId() != null) {
            FundManager m = fundManagerMapper.selectById(fund.getManagerId());
            if (m != null) dto.setManagerName(m.getName());
        }
        LambdaQueryWrapper<FundTagRelation> relWrapper = Wrappers.lambdaQuery();
        relWrapper.eq(FundTagRelation::getFundId, fundId);
        List<FundTagRelation> relations = fundTagRelationMapper.selectList(relWrapper);
        if (!relations.isEmpty()) {
            List<Long> tagIds = relations.stream().map(FundTagRelation::getTagId).collect(Collectors.toList());
            List<Tag> tags = tagMapper.selectBatchIds(tagIds);
            dto.setTags(tags.stream().map(Tag::getName).collect(Collectors.toList()));
        } else { dto.setTags(Collections.emptyList()); }
        LocalDate oneYearAgo = LocalDate.now().minusDays(260);
        LambdaQueryWrapper<FundNav> navWrapper = Wrappers.lambdaQuery();
        navWrapper.eq(FundNav::getFundId, fundId)
                  .between(FundNav::getDate, oneYearAgo, LocalDate.now())
                  .orderByAsc(FundNav::getDate);
        List<FundNav> navList = fundNavMapper.selectList(navWrapper);
        dto.setNavSeries(navList.stream().map(n ->
                new FundProfileDTO.NavPoint(n.getDate().toString(), n.getUnitNav(), n.getAccumNav())
        ).collect(Collectors.toList()));
        LambdaQueryWrapper<FundSector> sectorWrapper = Wrappers.lambdaQuery();
        sectorWrapper.eq(FundSector::getFundId, fundId);
        List<FundSector> sectors = fundSectorMapper.selectList(sectorWrapper);
        dto.setSectors(sectors.stream().map(s ->
                new FundProfileDTO.SectorItem(s.getSectorName(), s.getRatio())
        ).collect(Collectors.toList()));
        LambdaQueryWrapper<FundStock> stockWrapper = Wrappers.lambdaQuery();
        stockWrapper.eq(FundStock::getFundId, fundId);
        List<FundStock> stocks = fundStockMapper.selectList(stockWrapper);
        dto.setTopHoldings(stocks.stream().map(s ->
                new FundProfileDTO.StockItem(s.getStockName(), s.getRatio())
        ).collect(Collectors.toList()));
        LambdaQueryWrapper<FundAnnouncement> annWrapper = Wrappers.lambdaQuery();
        annWrapper.eq(FundAnnouncement::getFundId, fundId)
                  .orderByDesc(FundAnnouncement::getPublishDate)
                  .last("LIMIT 5");
        List<FundAnnouncement> announcements = fundAnnouncementMapper.selectList(annWrapper);
        dto.setAnnouncements(announcements.stream().map(a ->
                new FundProfileDTO.AnnouncementItem(a.getTitle(), a.getPublishDate())
        ).collect(Collectors.toList()));
        return dto;
    }

    // ==================== 鸿蒙 ====================
    @Override
    @Transactional(readOnly = true)
    public FundNavDTO getFundNav(String code) {
        Fund fund = fundMapper.selectOne(Wrappers.<Fund>lambdaQuery().eq(Fund::getCode, code));
        if (fund == null) throw new RuntimeException("基金代码不存在");
        FundNavDTO dto = new FundNavDTO();
        dto.setCode(fund.getCode()); dto.setName(fund.getName());
        LambdaQueryWrapper<FundNav> navWrapper = Wrappers.lambdaQuery();
        navWrapper.eq(FundNav::getFundId, fund.getId())
                  .orderByDesc(FundNav::getDate)
                  .last("LIMIT 1");
        FundNav latestNav = fundNavMapper.selectOne(navWrapper);
        if (latestNav != null) {
            dto.setUnitNav(latestNav.getUnitNav());
            dto.setNavDate(latestNav.getDate().toString());
            dto.setDailyReturn(latestNav.getDailyReturn());
        }
        return dto;
    }

    // ==================== 公司 ====================
    @Override @Transactional(readOnly = true)
    public Page<FundCompanyDTO> searchCompanies(String keyword, List<Long> tagIds, int page, int size) {
        if (size <= 0 || size > 100) size = PAGE_SIZE;
        int mpPage = page + 1;
        LambdaQueryWrapper<FundCompany> wrapper = Wrappers.lambdaQuery();
        if (keyword != null && !keyword.isEmpty()) wrapper.like(FundCompany::getName, keyword);
        Page<FundCompany> companyPage = fundCompanyMapper.selectPage(new Page<>(mpPage, size), wrapper);
        Page<FundCompanyDTO> dtoPage = new Page<>(companyPage.getCurrent(), companyPage.getSize(), companyPage.getTotal());
        dtoPage.setRecords(companyPage.getRecords().stream().map(this::toCompanyDTO).collect(Collectors.toList()));
        return dtoPage;
    }
    private FundCompanyDTO toCompanyDTO(FundCompany company) {
        FundCompanyDTO dto = new FundCompanyDTO();
        dto.setId(company.getId()); dto.setName(company.getName()); dto.setDescription(company.getDescription());
        dto.setFundCount(fundMapper.selectCount(Wrappers.<Fund>lambdaQuery().eq(Fund::getCompanyId, company.getId())));
        return dto;
    }
    @Override @Transactional(readOnly = true)
    public FundCompanyDTO getCompanyDetail(Long companyId) {
        FundCompany company = fundCompanyMapper.selectById(companyId);
        if (company == null) throw new RuntimeException("公司不存在");
        return toCompanyDTO(company);
    }
    @Override @Transactional(readOnly = true)
    public Page<FundListDTO> getCompanyFunds(Long companyId, List<Long> tagIds, int page, int size) {
        if (size <= 0 || size > 100) size = PAGE_SIZE;
        int mpPage = page + 1;
        LambdaQueryWrapper<Fund> wrapper = Wrappers.lambdaQuery();
        wrapper.eq(Fund::getCompanyId, companyId);
        if (tagIds != null && !tagIds.isEmpty()) {
            List<Long> fundIds = fundTagRelationMapper.findFundIdsByAllTags(tagIds, tagIds.size());
            if (fundIds.isEmpty()) return new Page<>(mpPage, size, 0);
            wrapper.in(Fund::getId, fundIds);
        }
        Page<Fund> fundPage = fundMapper.selectPage(new Page<>(mpPage, size), wrapper);
        Page<FundListDTO> dtoPage = new Page<>(fundPage.getCurrent(), fundPage.getSize(), fundPage.getTotal());
        dtoPage.setRecords(fundPage.getRecords().stream().map(this::toFundListDTO).collect(Collectors.toList()));
        return dtoPage;
    }

    // ==================== 经理 ====================
    @Override @Transactional(readOnly = true)
    public Page<FundManagerDTO> searchManagers(String keyword, List<Long> tagIds, int page, int size) {
        if (size <= 0 || size > 100) size = PAGE_SIZE;
        int mpPage = page + 1;
        LambdaQueryWrapper<FundManager> wrapper = Wrappers.lambdaQuery();
        if (keyword != null && !keyword.isEmpty()) wrapper.like(FundManager::getName, keyword);
        Page<FundManager> managerPage = fundManagerMapper.selectPage(new Page<>(mpPage, size), wrapper);
        Page<FundManagerDTO> dtoPage = new Page<>(managerPage.getCurrent(), managerPage.getSize(), managerPage.getTotal());
        dtoPage.setRecords(managerPage.getRecords().stream().map(this::toManagerDTO).collect(Collectors.toList()));
        return dtoPage;
    }
    private FundManagerDTO toManagerDTO(FundManager manager) {
        FundManagerDTO dto = new FundManagerDTO();
        dto.setId(manager.getId());
        dto.setName(manager.getName());
        dto.setExperienceYears(manager.getExperienceYears());
        dto.setContact(manager.getContact());   // 新增
        dto.setBio(manager.getBio());           // 新增
        dto.setFundCount(fundMapper.selectCount(Wrappers.<Fund>lambdaQuery().eq(Fund::getManagerId, manager.getId())));
        return dto;
    }
    @Override @Transactional(readOnly = true)
    public FundManagerDTO getManagerDetail(Long managerId) {
        FundManager manager = fundManagerMapper.selectById(managerId);
        if (manager == null) throw new RuntimeException("经理不存在");
        return toManagerDTO(manager);
    }
    @Override @Transactional(readOnly = true)
    public Page<FundListDTO> getManagerFunds(Long managerId, List<Long> tagIds, int page, int size) {
        if (size <= 0 || size > 100) size = PAGE_SIZE;
        int mpPage = page + 1;
        LambdaQueryWrapper<Fund> wrapper = Wrappers.lambdaQuery();
        wrapper.eq(Fund::getManagerId, managerId);
        if (tagIds != null && !tagIds.isEmpty()) {
            List<Long> fundIds = fundTagRelationMapper.findFundIdsByAllTags(tagIds, tagIds.size());
            if (fundIds.isEmpty()) return new Page<>(mpPage, size, 0);
            wrapper.in(Fund::getId, fundIds);
        }
        Page<Fund> fundPage = fundMapper.selectPage(new Page<>(mpPage, size), wrapper);
        Page<FundListDTO> dtoPage = new Page<>(fundPage.getCurrent(), fundPage.getSize(), fundPage.getTotal());
        dtoPage.setRecords(fundPage.getRecords().stream().map(this::toFundListDTO).collect(Collectors.toList()));
        return dtoPage;
    }

    // ==================== 标签 ====================
    @Override @Transactional(readOnly = true)
    public List<TagTreeNodeDTO> getTagTree(String dimension) {
        LambdaQueryWrapper<Tag> wrapper = Wrappers.lambdaQuery();
        if (dimension != null && !dimension.isEmpty()) wrapper.eq(Tag::getDimension, dimension);
        List<Tag> allTags = tagMapper.selectList(wrapper);
        Map<Long, TagTreeNodeDTO> nodeMap = new HashMap<>();
        List<TagTreeNodeDTO> roots = new ArrayList<>();
        for (Tag tag : allTags) {
            TagTreeNodeDTO node = new TagTreeNodeDTO(tag.getId(), tag.getName(), tag.getDimension(), tag.getParentId());
            node.setChildren(new ArrayList<>());
            nodeMap.put(tag.getId(), node);
        }
        for (Tag tag : allTags) {
            TagTreeNodeDTO node = nodeMap.get(tag.getId());
            if (tag.getParentId() == null) {
                roots.add(node);
            } else {
                TagTreeNodeDTO parent = nodeMap.get(tag.getParentId());
                if (parent != null) parent.getChildren().add(node);
                else roots.add(node);
            }
        }
        return roots;
    }

    // ==================== 组合 ====================
    @Override @Transactional(readOnly = true)
    public List<Portfolio> getUserPortfolios(Long userId) {
        return portfolioMapper.selectList(Wrappers.<Portfolio>lambdaQuery()
                .eq(Portfolio::getUserId, userId).orderByDesc(Portfolio::getCreatedTime));
    }
    @Override @Transactional(readOnly = true)
    public PortfolioDTO getPortfolioDetail(Long portfolioId) {
        Portfolio portfolio = portfolioMapper.selectById(portfolioId);
        if (portfolio == null) throw new RuntimeException("组合不存在");
        PortfolioDTO dto = new PortfolioDTO();
        dto.setId(portfolio.getId()); dto.setUserId(portfolio.getUserId());
        dto.setName(portfolio.getName()); dto.setCreatedTime(portfolio.getCreatedTime());
        List<PortfolioItem> items = portfolioItemMapper.selectList(
                Wrappers.<PortfolioItem>lambdaQuery().eq(PortfolioItem::getPortfolioId, portfolioId));
        dto.setFunds(items.stream().map(item -> {
            PortfolioDTO.PortfolioFundItem fi = new PortfolioDTO.PortfolioFundItem();
            fi.setFundId(item.getFundId());
            Fund f = fundMapper.selectById(item.getFundId());
            if (f != null) { fi.setFundCode(f.getCode()); fi.setFundName(f.getName()); fi.setFundType(f.getType()); }
            return fi;
        }).collect(Collectors.toList()));
        return dto;
    }
    @Override
    public Portfolio createPortfolio(Long userId, String name, List<Long> fundIds) {
        if (fundIds == null || fundIds.isEmpty()) throw new RuntimeException("至少选择一只基金");
        if (name == null || name.trim().isEmpty()) throw new RuntimeException("组合名称不能为空");
        Portfolio portfolio = new Portfolio();
        portfolio.setUserId(userId); portfolio.setName(name.trim()); portfolio.setCreatedTime(LocalDateTime.now());
        portfolioMapper.insert(portfolio);
        for (Long fundId : fundIds) {
            PortfolioItem item = new PortfolioItem(); item.setPortfolioId(portfolio.getId()); item.setFundId(fundId);
            portfolioItemMapper.insert(item);
        }
        return portfolio;
    }
    @Override
    public void deletePortfolio(Long portfolioId) {
        if (portfolioMapper.selectById(portfolioId) == null) throw new RuntimeException("组合不存在");
        portfolioItemMapper.delete(Wrappers.<PortfolioItem>lambdaQuery().eq(PortfolioItem::getPortfolioId, portfolioId));
        portfolioMapper.deleteById(portfolioId);
    }

    // ==================== 用户 ====================
    @Override
    public User register(String username, String password) {
        if (username == null || username.trim().isEmpty()) throw new RuntimeException("用户名不能为空");
        if (password == null || password.trim().isEmpty()) throw new RuntimeException("密码不能为空");
        if (userMapper.selectCount(Wrappers.<User>lambdaQuery().eq(User::getUsername, username)) > 0)
            throw new RuntimeException("用户名已存在");
        User user = new User();
        user.setUsername(username.trim()); user.setPassword(password);
        user.setCreateTime(LocalDateTime.now()); user.setNickname(username);
        userMapper.insert(user);
        return user;
    }
    @Override @Transactional(readOnly = true)
    public User login(String username, String password) {
        User user = userMapper.selectOne(Wrappers.<User>lambdaQuery().eq(User::getUsername, username));
        if (user == null || !user.getPassword().equals(password)) throw new RuntimeException("用户名或密码错误");
        return user;
    }

    // ==================== AI ====================
    @Override
    public String chat(String message) {
        try {
            String url = "http://localhost:11434/api/generate";
            Map<String, Object> body = new HashMap<>();
            body.put("model", "deepseek-r1:1.5b");
            body.put("prompt", message);
            body.put("stream", false);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(body, headers);
            ResponseEntity<Map> response = restTemplate.postForEntity(url, requestEntity, Map.class);
            if (response.getBody() != null && response.getBody().get("response") != null) {
                return (String) response.getBody().get("response");
            }
            return "AI 服务返回异常";
        } catch (Exception e) {
            log.error("调用 Ollama 失败", e);
            return "AI 服务繁忙，请稍后重试";
        }
    }

    @Override
    public void initMockData() {
        log.warn("initMockData 已禁用，请使用 data.sql 脚本初始化数据");
    }
}



