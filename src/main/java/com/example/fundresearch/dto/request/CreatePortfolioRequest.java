package com.example.fundresearch.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

/**
 * 创建组合请求
 */
public class CreatePortfolioRequest {

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotBlank(message = "组合名称不能为空")
    private String name;

    @NotEmpty(message = "至少选择一只基金")
    private List<@NotNull Long> fundIds;

    // Getters & Setters
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public List<Long> getFundIds() { return fundIds; }
    public void setFundIds(List<Long> fundIds) { this.fundIds = fundIds; }
}
