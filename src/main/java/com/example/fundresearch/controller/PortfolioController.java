package com.example.fundresearch.controller;

import com.example.fundresearch.common.Result;
import com.example.fundresearch.dto.PortfolioDTO;
import com.example.fundresearch.dto.request.CreatePortfolioRequest;
import com.example.fundresearch.entity.Portfolio;
import com.example.fundresearch.service.FundService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 组合管理控制器
 *
 * 提供接口：
 * - POST   /api/portfolios           创建组合（需登录）
 * - GET    /api/portfolios           获取用户所有组合（需登录）
 * - GET    /api/portfolios/{id}      组合详情（含基金列表）
 * - DELETE /api/portfolios/{id}      删除组合
 */
@RestController
@RequestMapping("/api/portfolios")
public class PortfolioController {

    private final FundService fundService;

    public PortfolioController(FundService fundService) {
        this.fundService = fundService;
    }

    /**
     * 获取用户所有组合
     *
     * GET /api/portfolios?userId=1
     *
     * @param userId 用户ID（通过请求参数传递，简化session管理）
     */
    @GetMapping
    public Result<List<Portfolio>> listPortfolios(
            @RequestParam Long userId) {
        List<Portfolio> portfolios = fundService.getUserPortfolios(userId);
        return Result.success(portfolios);
    }

    /**
     * 组合详情
     *
     * GET /api/portfolios/1
     */
    @GetMapping("/{id}")
    public Result<PortfolioDTO> getPortfolioDetail(@PathVariable Long id) {
        PortfolioDTO detail = fundService.getPortfolioDetail(id);
        return Result.success(detail);
    }

    /**
     * 创建组合
     *
     * POST /api/portfolios
     * 请求体：{ "userId": 1, "name": "我的组合", "fundIds": [1, 2, 3] }
     *
     * 校验：
     * - 必须登录（userId）
     * - 组合名称非空
     * - 至少选择一只基金
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Result<Portfolio> createPortfolio(@RequestBody @Valid CreatePortfolioRequest request) {
        Portfolio created = fundService.createPortfolio(request.getUserId(), request.getName(), request.getFundIds());
        return Result.success("组合创建成功", created);
    }

    /**
     * 删除组合
     *
     * DELETE /api/portfolios/1
     * 二次确认由前端完成
     */
    @DeleteMapping("/{id}")
    public Result<Void> deletePortfolio(@PathVariable Long id) {
        fundService.deletePortfolio(id);
        return Result.success("组合删除成功", null);
    }
}
