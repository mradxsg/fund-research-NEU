package com.example.fundresearch.dto;

/**
 * 基金经理列表 / 详情 DTO
 */
public class FundManagerDTO {

    private Long id;
    private String name;
    private Integer experienceYears;
    private String companyName;    // 所属公司名称（可空）
    private long fundCount;        // 在管基金数

    // ===== 新增字段 =====
    private String contact;        // 联系方式
    private String bio;            // 简介

    public FundManagerDTO() {}

    // 完整构造器（可按需保留）
    public FundManagerDTO(Long id, String name, Integer experienceYears,
                          String companyName, long fundCount,
                          String contact, String bio) {
        this.id = id;
        this.name = name;
        this.experienceYears = experienceYears;
        this.companyName = companyName;
        this.fundCount = fundCount;
        this.contact = contact;
        this.bio = bio;
    }

    // ===== Getters & Setters =====
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

    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
}
