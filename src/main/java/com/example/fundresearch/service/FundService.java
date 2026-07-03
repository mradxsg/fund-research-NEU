package com.example.fundresearch.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.fundresearch.dto.*;
import com.example.fundresearch.entity.*;

import java.util.List;

/**
 * 基金研究子系统 — 核心业务接口
 */
public interface FundService {

    // ==================== 基金查询 ====================
    Page<FundListDTO> searchFunds(String keyword, String type, String riskLevel,
                                  List<Long> tagIds, int page, int size);

    FundProfileDTO getFundProfile(Long fundId);

    FundNavDTO getFundNav(String code);

    // ==================== 公司查询 ====================
    Page<FundCompanyDTO> searchCompanies(String keyword, List<Long> tagIds, int page, int size);
    FundCompanyDTO getCompanyDetail(Long companyId);
    Page<FundListDTO> getCompanyFunds(Long companyId, List<Long> tagIds, int page, int size);

    // ==================== 经理查询 ====================
    Page<FundManagerDTO> searchManagers(String keyword, List<Long> tagIds, int page, int size);
    FundManagerDTO getManagerDetail(Long managerId);
    Page<FundListDTO> getManagerFunds(Long managerId, List<Long> tagIds, int page, int size);

    // ==================== 标签树 ====================
    List<TagTreeNodeDTO> getTagTree(String dimension);

    // ==================== 组合管理 ====================
    List<Portfolio> getUserPortfolios(Long userId);
    PortfolioDTO getPortfolioDetail(Long portfolioId);
    Portfolio createPortfolio(Long userId, String name, List<Long> fundIds);
    void deletePortfolio(Long portfolioId);

    // ==================== 用户模块 ====================
    User register(String username, String password);
    User login(String username, String password);

    // ==================== AI 对话 ====================
    String chat(String message);

    // ==================== 数据初始化 ====================
    void initMockData();
}



