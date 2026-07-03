package com.example.fundresearch.dto;

import java.math.BigDecimal;

/**
 * 鸿蒙元服务专用 — 基金净值 DTO（精简版）
 * 返回最小数据集，降低鸿蒙端解析开销
 */
public class FundNavDTO {

    private String code;
    private String name;
    private BigDecimal unitNav;       // 最新单位净值
    private String navDate;           // 净值日期
    private BigDecimal dailyReturn;   // 日涨跌幅(%)

    public FundNavDTO() {}

    public FundNavDTO(String code, String name, BigDecimal unitNav,
                      String navDate, BigDecimal dailyReturn) {
        this.code = code;
        this.name = name;
        this.unitNav = unitNav;
        this.navDate = navDate;
        this.dailyReturn = dailyReturn;
    }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getUnitNav() { return unitNav; }
    public void setUnitNav(BigDecimal unitNav) { this.unitNav = unitNav; }

    public String getNavDate() { return navDate; }
    public void setNavDate(String navDate) { this.navDate = navDate; }

    public BigDecimal getDailyReturn() { return dailyReturn; }
    public void setDailyReturn(BigDecimal dailyReturn) { this.dailyReturn = dailyReturn; }
}
