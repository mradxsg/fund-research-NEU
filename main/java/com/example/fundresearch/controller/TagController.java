package com.example.fundresearch.controller;

import com.example.fundresearch.common.Result;
import com.example.fundresearch.dto.TagTreeNodeDTO;
import com.example.fundresearch.service.FundService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 标签树控制器
 *
 * 提供接口：
 * - GET /api/tags?dimension=fund  获取标签树（按维度）
 */
@RestController
@RequestMapping("/api/tags")
public class TagController {

    private final FundService fundService;

    public TagController(FundService fundService) {
        this.fundService = fundService;
    }

    /**
     * 获取标签树形数据
     *
     * GET /api/tags?dimension=fund
     * GET /api/tags?dimension=company
     * GET /api/tags?dimension=manager
     *
     * @param dimension 维度：fund / company / manager（可空，返回全部）
     * @return 树形标签 JSON
     */
    @GetMapping
    public Result<List<TagTreeNodeDTO>> getTagTree(
            @RequestParam(required = false) String dimension) {
        List<TagTreeNodeDTO> tree = fundService.getTagTree(dimension);
        return Result.success(tree);
    }
}
