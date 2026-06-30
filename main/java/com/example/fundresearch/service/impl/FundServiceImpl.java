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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class FundServiceImpl implements FundService {

    private static final Logger log = LoggerFactory.getLogger(FundServiceImpl.class);
    private static final int PAGE_SIZE = 20;

    private final FundMapper fundMapper;
    private final FundNavMapper fundNavMapper;
    private final FundCompanyMapper fundCompanyMapper;
    private final FundManagerMapper fundManagerMapper;
    private final TagMapper tagMapper;
    private final FundTagRelationMapper fundTagRelationMapper;
    private final PortfolioMapper portfolioMapper;
    private final PortfolioItemMapper portfolioItemMapper;
    private final UserMapper userMapper;
    private final FundAnnouncementMapper fundAnnouncementMapper;
    private final FundSectorMapper fundSectorMapper;
    private final FundStockMapper fundStockMapper;

    public FundServiceImpl(FundMapper fundMapper,
                           FundNavMapper fundNavMapper,
                           FundCompanyMapper fundCompanyMapper,
                           FundManagerMapper fundManagerMapper,
                           TagMapper tagMapper,
                           FundTagRelationMapper fundTagRelationMapper,
                           PortfolioMapper portfolioMapper,
                           PortfolioItemMapper portfolioItemMapper,
                           UserMapper userMapper,
                           FundAnnouncementMapper fundAnnouncementMapper,
                           FundSectorMapper fundSectorMapper,
                           FundStockMapper fundStockMapper) {
        this.fundMapper = fundMapper;
        this.fundNavMapper = fundNavMapper;
        this.fundCompanyMapper = fundCompanyMapper;
        this.fundManagerMapper = fundManagerMapper;
        this.tagMapper = tagMapper;
        this.fundTagRelationMapper = fundTagRelationMapper;
        this.portfolioMapper = portfolioMapper;
        this.portfolioItemMapper = portfolioItemMapper;
        this.userMapper = userMapper;
        this.fundAnnouncementMapper = fundAnnouncementMapper;
        this.fundSectorMapper = fundSectorMapper;
        this.fundStockMapper = fundStockMapper;
    }

    // ==================== 基金查询 ====================

    @Override
    @Transactional(readOnly = true)
    public Page<FundListDTO> searchFunds(String keyword, String type, String riskLevel,
                                         List<Long> tagIds, int page, int size) {
        if (size <= 0 || size > 100) size = PAGE_SIZE;
        // 修正：Controller 传 0 为第一页，MyBatis-Plus 从 1 开始
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
        // 标签交集筛选
        if (tagIds != null && !tagIds.isEmpty()) {
            List<Long> fundIds = fundTagRelationMapper.findFundIdsByAllTags(tagIds, tagIds.size());
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

    @Override
    @Transactional(readOnly = true)
    public FundProfileDTO getFundProfile(Long fundId) {
        Fund fund = fundMapper.selectById(fundId);
        if (fund == null) {
            throw new RuntimeException("基金 ID " + fundId + " 不存在");
        }

        FundProfileDTO dto = new FundProfileDTO();
        dto.setId(fund.getId());
        dto.setCode(fund.getCode());
        dto.setName(fund.getName());
        dto.setType(fund.getType());
        dto.setScale(fund.getScale());
        dto.setEstablishDate(fund.getEstablishDate());
        dto.setRiskLevel(fund.getRiskLevel());
        dto.setBenchmark(fund.getBenchmark());
        dto.setAttributionText(fund.getAttributionText());

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
        } else {
            dto.setTags(Collections.emptyList());
        }

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

    @Override
    @Transactional(readOnly = true)
    public FundNavDTO getFundNav(String code) {
        LambdaQueryWrapper<Fund> fundWrapper = Wrappers.lambdaQuery();
        fundWrapper.eq(Fund::getCode, code);
        Fund fund = fundMapper.selectOne(fundWrapper);
        if (fund == null) {
            throw new RuntimeException("基金代码 " + code + " 不存在");
        }

        FundNavDTO dto = new FundNavDTO();
        dto.setCode(fund.getCode());
        dto.setName(fund.getName());

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

    // ==================== 公司查询 ====================

    @Override
    @Transactional(readOnly = true)
    public Page<FundCompanyDTO> searchCompanies(String keyword, List<Long> tagIds, int page, int size) {
        if (size <= 0 || size > 100) size = PAGE_SIZE;
        int mpPage = page + 1;

        if (tagIds != null && !tagIds.isEmpty()) {
            List<Long> fundIds = fundTagRelationMapper.findFundIdsByAllTags(tagIds, tagIds.size());
            if (fundIds.isEmpty()) {
                return new Page<>(mpPage, size, 0);
            }
            List<Fund> funds = fundMapper.selectBatchIds(fundIds);
            Set<Long> companyIds = funds.stream()
                    .map(Fund::getCompanyId).filter(Objects::nonNull).collect(Collectors.toSet());
            if (companyIds.isEmpty()) {
                return new Page<>(mpPage, size, 0);
            }
            List<FundCompany> companies = fundCompanyMapper.selectBatchIds(companyIds);
            int start = Math.min(page * size, companies.size());
            int end = Math.min(start + size, companies.size());
            List<FundCompany> pageContent = companies.subList(start, end);
            Page<FundCompanyDTO> resultPage = new Page<>(mpPage, size, companies.size());
            resultPage.setRecords(pageContent.stream().map(this::toCompanyDTO).collect(Collectors.toList()));
            return resultPage;
        }

        LambdaQueryWrapper<FundCompany> wrapper = Wrappers.lambdaQuery();
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(FundCompany::getName, keyword);
        }
        Page<FundCompany> companyPage = fundCompanyMapper.selectPage(new Page<>(mpPage, size), wrapper);
        Page<FundCompanyDTO> dtoPage = new Page<>(companyPage.getCurrent(), companyPage.getSize(), companyPage.getTotal());
        dtoPage.setRecords(companyPage.getRecords().stream().map(this::toCompanyDTO).collect(Collectors.toList()));
        return dtoPage;
    }

    private FundCompanyDTO toCompanyDTO(FundCompany company) {
        FundCompanyDTO dto = new FundCompanyDTO();
        dto.setId(company.getId());
        dto.setName(company.getName());
        dto.setDescription(company.getDescription());
        LambdaQueryWrapper<Fund> fundWrapper = Wrappers.lambdaQuery();
        fundWrapper.eq(Fund::getCompanyId, company.getId());
        dto.setFundCount(fundMapper.selectCount(fundWrapper));
        return dto;
    }

    @Override
    public FundCompanyDTO getCompanyDetail(Long companyId) {
        FundCompany company = fundCompanyMapper.selectById(companyId);
        if (company == null) throw new RuntimeException("公司 ID " + companyId + " 不存在");
        return toCompanyDTO(company);
    }

    @Override
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

    // ==================== 经理查询 ====================

    @Override
    public Page<FundManagerDTO> searchManagers(String keyword, List<Long> tagIds, int page, int size) {
        if (size <= 0 || size > 100) size = PAGE_SIZE;
        int mpPage = page + 1;

        if (tagIds != null && !tagIds.isEmpty()) {
            List<Long> fundIds = fundTagRelationMapper.findFundIdsByAllTags(tagIds, tagIds.size());
            if (fundIds.isEmpty()) return new Page<>(mpPage, size, 0);
            List<Fund> funds = fundMapper.selectBatchIds(fundIds);
            Set<Long> managerIds = funds.stream().map(Fund::getManagerId).filter(Objects::nonNull).collect(Collectors.toSet());
            if (managerIds.isEmpty()) return new Page<>(mpPage, size, 0);
            List<FundManager> managers = fundManagerMapper.selectBatchIds(managerIds);
            int start = Math.min(page * size, managers.size());
            int end = Math.min(start + size, managers.size());
            List<FundManager> pageContent = managers.subList(start, end);
            Page<FundManagerDTO> resultPage = new Page<>(mpPage, size, managers.size());
            resultPage.setRecords(pageContent.stream().map(this::toManagerDTO).collect(Collectors.toList()));
            return resultPage;
        }

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
        LambdaQueryWrapper<Fund> fundWrapper = Wrappers.lambdaQuery();
        fundWrapper.eq(Fund::getManagerId, manager.getId());
        dto.setFundCount(fundMapper.selectCount(fundWrapper));
        return dto;
    }

    @Override
    public FundManagerDTO getManagerDetail(Long managerId) {
        FundManager manager = fundManagerMapper.selectById(managerId);
        if (manager == null) throw new RuntimeException("经理 ID " + managerId + " 不存在");
        return toManagerDTO(manager);
    }

    @Override
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

    // ==================== 标签树 ====================
    @Override
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
                if (parent != null) {
                    parent.getChildren().add(node);
                } else {
                    roots.add(node);
                }
            }
        }
        return roots;
    }

    // ==================== 组合管理 ====================
    @Override public List<Portfolio> getUserPortfolios(Long userId) {
        return portfolioMapper.selectList(Wrappers.<Portfolio>lambdaQuery().eq(Portfolio::getUserId, userId).orderByDesc(Portfolio::getCreatedTime));
    }

    @Override public PortfolioDTO getPortfolioDetail(Long portfolioId) {
        Portfolio portfolio = portfolioMapper.selectById(portfolioId);
        if (portfolio == null) throw new RuntimeException("组合不存在");
        PortfolioDTO dto = new PortfolioDTO();
        dto.setId(portfolio.getId());
        dto.setUserId(portfolio.getUserId());
        dto.setName(portfolio.getName());
        dto.setCreatedTime(portfolio.getCreatedTime());
        List<PortfolioItem> items = portfolioItemMapper.selectList(Wrappers.<PortfolioItem>lambdaQuery().eq(PortfolioItem::getPortfolioId, portfolioId));
        dto.setFunds(items.stream().map(item -> {
            PortfolioDTO.PortfolioFundItem fi = new PortfolioDTO.PortfolioFundItem();
            fi.setFundId(item.getFundId());
            Fund f = fundMapper.selectById(item.getFundId());
            if (f != null) {
                fi.setFundCode(f.getCode());
                fi.setFundName(f.getName());
                fi.setFundType(f.getType());
            }
            return fi;
        }).collect(Collectors.toList()));
        return dto;
    }

    @Override public Portfolio createPortfolio(Long userId, String name, List<Long> fundIds) {
        if (fundIds == null || fundIds.isEmpty()) throw new RuntimeException("至少选择一只基金");
        if (name == null || name.trim().isEmpty()) throw new RuntimeException("组合名称不能为空");
        Portfolio portfolio = new Portfolio();
        portfolio.setUserId(userId);
        portfolio.setName(name.trim());
        portfolio.setCreatedTime(LocalDateTime.now());
        portfolioMapper.insert(portfolio);
        for (Long fid : fundIds) {
            PortfolioItem item = new PortfolioItem();
            item.setPortfolioId(portfolio.getId());
            item.setFundId(fid);
            portfolioItemMapper.insert(item);
        }
        return portfolio;
    }

    @Override public void deletePortfolio(Long portfolioId) {
        if (portfolioMapper.selectById(portfolioId) == null) throw new RuntimeException("组合不存在");
        portfolioItemMapper.delete(Wrappers.<PortfolioItem>lambdaQuery().eq(PortfolioItem::getPortfolioId, portfolioId));
        portfolioMapper.deleteById(portfolioId);
    }

    // ==================== 用户 ====================
    @Override public User register(String username, String password) {
        if (username == null || username.trim().isEmpty()) throw new RuntimeException("用户名不能为空");
        if (password == null || password.trim().isEmpty()) throw new RuntimeException("密码不能为空");
        User user = new User();
        user.setUsername(username.trim());
        user.setPassword(password);
        user.setCreateTime(LocalDateTime.now());
        userMapper.insert(user);
        return user;
    }

    @Override public User login(String username, String password) {
        User user = userMapper.selectOne(Wrappers.<User>lambdaQuery().eq(User::getUsername, username));
        if (user == null || !user.getPassword().equals(password)) throw new RuntimeException("用户名或密码错误");
        return user;
    }

    // ==================== AI ====================
    @Override public String chat(String message) {
        log.info("AI对话请求: {}", message);
        return "抱歉，我只能回答基金相关的问题。请问您想了解哪只基金的信息？";
    }

    // ==================== 数据初始化（已停用） ====================
    @Override
    public void initMockData() {
        log.warn("initMockData 已禁用，请使用 data.sql 脚本初始化数据");
    }
}



