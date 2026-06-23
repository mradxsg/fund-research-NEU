package com.example.fundresearch.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.fundresearch.common.Result;
import com.example.fundresearch.entity.Fund;
import com.example.fundresearch.service.FundService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/funds")
public class FundController {

    @Autowired
    private FundService fundService;

    @GetMapping
    public Result<Map<String, Object>> list(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String tagIds,
            @RequestParam(defaultValue = "1") int page) {

        // 解析 tagIds 字符串为 List<Long>
        List<Long> tagIdList = null;
        if (tagIds != null && !tagIds.isEmpty()) {
            tagIdList = Arrays.stream(tagIds.split(","))
                              .map(Long::parseLong)
                              .collect(Collectors.toList());
        }

        IPage<Fund> result = fundService.queryFunds(keyword, tagIdList, page, 20);

        Map<String, Object> data = new HashMap<>();
        data.put("records", result.getRecords());
        data.put("total", result.getTotal());
        data.put("page", page);
        data.put("size", 20);
        return Result.success(data);
    }
}


