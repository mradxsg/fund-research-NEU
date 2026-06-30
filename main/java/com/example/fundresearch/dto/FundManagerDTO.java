package com.example.fundresearch.dto;

import java.math.BigDecimal;

/**
 * 基金经理列表 DTO
 */
public class FundManagerDTO {

    private Long id;
    private String name;
    private Integer experienceYears;
    private String companyName;
    private long fundCount;  // 在管基金数

    public FundManagerDTO() {}

    public FundManagerDTO(Long id, String name, Integer experienceYears,
                          String companyName, long fundCount) {
        this.id = id;
        this.name = name;
        this.experienceYears = experienceYears;
        this.companyName = companyName;
        this.fundCount = fundCount;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getExperienceYears() { return experienceYears; }
    public void setExperienceYears(Integer experienceYears) { this.experienceYears = experienceYears; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public long getFundCount() { return fundCount; }
    public void setFundCount(long fundCount) { this.fundCount = fundCount; }
}
