package com.example.fundresearch.dto;

import java.math.BigDecimal;

/**
 * 基金列表 DTO（基金查询结果用）
 * 字段匹配前端表格列定义
 */
public class FundListDTO {

    private Long id;
    private String code;
    private String name;
    private String type;
    private BigDecimal unitNav;       // 最新单位净值
    private BigDecimal dailyReturn;   // 日涨跌幅(%)
    private String riskLevel;

    public FundListDTO() {}

    public FundListDTO(Long id, String code, String name, String type,
                       BigDecimal unitNav, BigDecimal dailyReturn, String riskLevel) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.type = type;
        this.unitNav = unitNav;
        this.dailyReturn = dailyReturn;
        this.riskLevel = riskLevel;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public BigDecimal getUnitNav() { return unitNav; }
    public void setUnitNav(BigDecimal unitNav) { this.unitNav = unitNav; }

    public BigDecimal getDailyReturn() { return dailyReturn; }
    public void setDailyReturn(BigDecimal dailyReturn) { this.dailyReturn = dailyReturn; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
}
