package com.example.fundresearch.controller;

import com.example.fundresearch.common.Result;
import com.example.fundresearch.dto.FundCompanyDTO;
import com.example.fundresearch.dto.FundListDTO;
import com.example.fundresearch.service.FundService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 基金公司查询控制器
 *
 * 提供接口：
 * - GET /api/companies           公司列表查询/筛选
 * - GET /api/companies/{id}      公司详情
 * - GET /api/companies/{id}/funds 公司旗下基金列表
 */
@RestController
@RequestMapping("/api/companies")
public class CompanyController {

    private final FundService fundService;

    public CompanyController(FundService fundService) {
        this.fundService = fundService;
    }

    /**
     * 公司列表查询
     *
     * GET /api/companies?keyword=华夏&tagIds=1,2&page=0
     */
    @GetMapping
    public Result<Page<FundCompanyDTO>> listCompanies(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) List<Long> tagIds,
            @RequestParam(defaultValue = "0") int page) {
        Page<FundCompanyDTO> result = fundService.searchCompanies(keyword, tagIds, page, 20);
        return Result.success(result);
    }

    /**
     * 公司详情
     *
     * GET /api/companies/1
     */
    @GetMapping("/{id}")
    public Result<FundCompanyDTO> getCompanyDetail(@PathVariable Long id) {
        FundCompanyDTO detail = fundService.getCompanyDetail(id);
        return Result.success(detail);
    }

    /**
     * 公司旗下基金列表
     *
     * GET /api/companies/1/funds?tagIds=1,2&page=0
     */
    @GetMapping("/{id}/funds")
    public Result<Page<FundListDTO>> getCompanyFunds(
            @PathVariable Long id,
            @RequestParam(required = false) List<Long> tagIds,
            @RequestParam(defaultValue = "0") int page) {
        Page<FundListDTO> result = fundService.getCompanyFunds(id, tagIds, page, 20);
        return Result.success(result);
    }
}
