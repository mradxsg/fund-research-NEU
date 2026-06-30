package com.example.fundresearch.dto;

import java.math.BigDecimal;

/**
 * 基金公司列表 DTO
 */
public class FundCompanyDTO {

    private Long id;
    private String name;
    private String description;
    private long fundCount;  // 旗下基金数量

    public FundCompanyDTO() {}

    public FundCompanyDTO(Long id, String name, String description, long fundCount) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.fundCount = fundCount;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public long getFundCount() { return fundCount; }
    public void setFundCount(long fundCount) { this.fundCount = fundCount; }
}
