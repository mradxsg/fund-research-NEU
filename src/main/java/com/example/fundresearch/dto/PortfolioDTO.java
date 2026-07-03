package com.example.fundresearch.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 组合详情 DTO
 */
public class PortfolioDTO {

    private Long id;
    private Long userId;
    private String name;
    private LocalDateTime createdTime;
    private List<PortfolioFundItem> funds;

    /** 组合内基金条目 */
    public static class PortfolioFundItem {
        private Long fundId;
        private String fundCode;
        private String fundName;
        private String fundType;

        public PortfolioFundItem() {}
        public PortfolioFundItem(Long fundId, String fundCode, String fundName, String fundType) {
            this.fundId = fundId;
            this.fundCode = fundCode;
            this.fundName = fundName;
            this.fundType = fundType;
        }

        public Long getFundId() { return fundId; }
        public void setFundId(Long fundId) { this.fundId = fundId; }
        public String getFundCode() { return fundCode; }
        public void setFundCode(String fundCode) { this.fundCode = fundCode; }
        public String getFundName() { return fundName; }
        public void setFundName(String fundName) { this.fundName = fundName; }
        public String getFundType() { return fundType; }
        public void setFundType(String fundType) { this.fundType = fundType; }
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public LocalDateTime getCreatedTime() { return createdTime; }
    public void setCreatedTime(LocalDateTime createdTime) { this.createdTime = createdTime; }

    public List<PortfolioFundItem> getFunds() { return funds; }
    public void setFunds(List<PortfolioFundItem> funds) { this.funds = funds; }
}
