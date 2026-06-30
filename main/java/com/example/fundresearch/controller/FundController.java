package com.example.fundresearch.controller;

import com.example.fundresearch.common.Result;
import com.example.fundresearch.dto.FundListDTO;
import com.example.fundresearch.dto.FundNavDTO;
import com.example.fundresearch.dto.FundProfileDTO;
import com.example.fundresearch.service.FundService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 基金查询控制器
 *
 * 提供接口：
 * - GET  /api/funds                   基金列表/筛选/分页
 * - GET  /api/funds/{id}              基金画像详情（含5个维度）
 * - GET  /api/funds/code/{code}       ★鸿蒙元服务净值查询
 * - GET  /api/funds/types             基金类型列表
 */
@RestController
@RequestMapping("/api/funds")
public class FundController {

    private final FundService fundService;

    public FundController(FundService fundService) {
        this.fundService = fundService;
    }

    /**
     * 基金列表查询（多条件筛选 + 分页）
     *
     * GET /api/funds?keyword=华夏&type=混合型&riskLevel=中风险&tagIds=1,2,3&page=0&size=20
     *
     * @param keyword  基金代码或名称模糊搜索
     * @param type     基金类型
     * @param riskLevel 风险等级
     * @param tagIds   标签ID列表（逗号分隔，取交集）
     * @param page     页码（从0开始）
     * @return 分页基金列表（含最新净值和涨跌幅）
     */
    @GetMapping
    public Result<Page<FundListDTO>> listFunds(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String riskLevel,
            @RequestParam(required = false) List<Long> tagIds,
            @RequestParam(defaultValue = "0") int page) {

        Page<FundListDTO> result = fundService.searchFunds(keyword, type, riskLevel, tagIds, page, 20);
        return Result.success(result);
    }

    /**
     * 基金画像详情
     *
     * GET /api/funds/1
     *
     * 返回5个维度数据：
     * 1. 基本信息（含公司/经理名称）
     * 2. 业绩走势（近1年净值序列）
     * 3. 持仓分析（行业配置饼图 + 前十大重仓股表格）
     * 4. 业绩归因（文本）
     * 5. 基金公告（最近5条）
     */
    @GetMapping("/{id}")
    public Result<FundProfileDTO> getFundProfile(@PathVariable Long id) {
        FundProfileDTO profile = fundService.getFundProfile(id);
        return Result.success(profile);
    }

    /**
     * ★ 鸿蒙元服务专用 — 单基金净值查询
     *
     * 为避免 REST 路由冲突（{id} 与 {code} 共用 /api/funds/{xxx}），
     * 使用 /api/funds/code/{code} 路径区分。
     *
     * GET /api/funds/code/000001
     *
     * 返回最小数据集供鸿蒙万能卡片渲染
     */
    @GetMapping("/code/{code}")
    public Result<FundNavDTO> getFundNav(@PathVariable String code) {
        FundNavDTO nav = fundService.getFundNav(code);
        return Result.success(nav);
    }

    /**
     * 获取所有基金类型
     *
     * GET /api/funds/types
     */
    @GetMapping("/types")
    public Result<List<String>> getFundTypes() {
        return Result.success(
                fundService.searchFunds(null, null, null, null, 0, 1)
                        .getRecords().stream()
                        .map(FundListDTO::getType)
                        .distinct()
                        .sorted()
                        .collect(java.util.stream.Collectors.toList())
        );
    }
}
