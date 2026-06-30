package com.example.fundresearch.controller;

import com.example.fundresearch.common.Result;
import com.example.fundresearch.dto.*;
import com.example.fundresearch.service.FundService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 基金经理查询控制器
 *
 * 提供接口：
 * - GET /api/managers            经理列表查询/筛选
 * - GET /api/managers/{id}       经理详情
 * - GET /api/managers/{id}/funds 经理管理基金列表
 */
@RestController
@RequestMapping("/api/managers")
public class ManagerController {

    private final FundService fundService;

    public ManagerController(FundService fundService) {
        this.fundService = fundService;
    }

    /**
     * 经理列表查询
     *
     * GET /api/managers?keyword=张坤&tagIds=1,2&page=0
     */
    @GetMapping
    public Result<Page<FundManagerDTO>> listManagers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) List<Long> tagIds,
            @RequestParam(defaultValue = "0") int page) {
        Page<FundManagerDTO> result = fundService.searchManagers(keyword, tagIds, page, 20);
        return Result.success(result);
    }

    /**
     * 经理详情
     *
     * GET /api/managers/1
     */
    @GetMapping("/{id}")
    public Result<FundManagerDTO> getManagerDetail(@PathVariable Long id) {
        FundManagerDTO detail = fundService.getManagerDetail(id);
        return Result.success(detail);
    }

    /**
     * 经理管理的基金列表
     *
     * GET /api/managers/1/funds?tagIds=1,2&page=0
     */
    @GetMapping("/{id}/funds")
    public Result<Page<FundListDTO>> getManagerFunds(
            @PathVariable Long id,
            @RequestParam(required = false) List<Long> tagIds,
            @RequestParam(defaultValue = "0") int page) {
        Page<FundListDTO> result = fundService.getManagerFunds(id, tagIds, page, 20);
        return Result.success(result);
    }
}
