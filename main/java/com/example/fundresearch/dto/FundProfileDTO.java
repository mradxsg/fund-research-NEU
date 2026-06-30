package com.example.fundresearch.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * 基金画像 DTO（画像页完整数据）
 * 包含 5 个维度：基本信息、业绩走势、持仓分析、业绩归因、公告
 */
public class FundProfileDTO {

    // ========== 基本信息 ==========
    private Long id;
    private String code;
    private String name;
    private String type;
    private BigDecimal scale;
    private LocalDate establishDate;
    private String companyName;
    private String managerName;
    private String riskLevel;
    private String benchmark;
    private List<String> tags;

    // ========== 业绩走势（净值序列） ==========
    private List<NavPoint> navSeries;

    // ========== 持仓分析 ==========
    private List<SectorItem> sectors;      // 行业配置（饼图）
    private List<StockItem> topHoldings;   // 前十大重仓股（表格）

    // ========== 业绩归因 ==========
    private String attributionText;

    // ========== 公告 ==========
    private List<AnnouncementItem> announcements;

    // ========== 嵌套类 ==========

    /** 净值时间点 */
    public static class NavPoint {
        private String date;
        private BigDecimal unitNav;
        private BigDecimal accumNav;

        public NavPoint() {}
        public NavPoint(String date, BigDecimal unitNav, BigDecimal accumNav) {
            this.date = date;
            this.unitNav = unitNav;
            this.accumNav = accumNav;
        }
        public String getDate() { return date; }
        public void setDate(String date) { this.date = date; }
        public BigDecimal getUnitNav() { return unitNav; }
        public void setUnitNav(BigDecimal unitNav) { this.unitNav = unitNav; }
        public BigDecimal getAccumNav() { return accumNav; }
        public void setAccumNav(BigDecimal accumNav) { this.accumNav = accumNav; }
    }

    /** 行业配置 */
    public static class SectorItem {
        private String sectorName;
        private BigDecimal ratio;

        public SectorItem() {}
        public SectorItem(String sectorName, BigDecimal ratio) {
            this.sectorName = sectorName;
            this.ratio = ratio;
        }
        public String getSectorName() { return sectorName; }
        public void setSectorName(String sectorName) { this.sectorName = sectorName; }
        public BigDecimal getRatio() { return ratio; }
        public void setRatio(BigDecimal ratio) { this.ratio = ratio; }
    }

    /** 重仓股 */
    public static class StockItem {
        private String stockName;
        private BigDecimal ratio;

        public StockItem() {}
        public StockItem(String stockName, BigDecimal ratio) {
            this.stockName = stockName;
            this.ratio = ratio;
        }
        public String getStockName() { return stockName; }
        public void setStockName(String stockName) { this.stockName = stockName; }
        public BigDecimal getRatio() { return ratio; }
        public void setRatio(BigDecimal ratio) { this.ratio = ratio; }
    }

    /** 公告 */
    public static class AnnouncementItem {
        private String title;
        private LocalDate publishDate;

        public AnnouncementItem() {}
        public AnnouncementItem(String title, LocalDate publishDate) {
            this.title = title;
            this.publishDate = publishDate;
        }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public LocalDate getPublishDate() { return publishDate; }
        public void setPublishDate(LocalDate publishDate) { this.publishDate = publishDate; }
    }

    // ========== Getters & Setters ==========

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public BigDecimal getScale() { return scale; }
    public void setScale(BigDecimal scale) { this.scale = scale; }

    public LocalDate getEstablishDate() { return establishDate; }
    public void setEstablishDate(LocalDate establishDate) { this.establishDate = establishDate; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getBenchmark() { return benchmark; }
    public void setBenchmark(String benchmark) { this.benchmark = benchmark; }

    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }

    public List<NavPoint> getNavSeries() { return navSeries; }
    public void setNavSeries(List<NavPoint> navSeries) { this.navSeries = navSeries; }

    public List<SectorItem> getSectors() { return sectors; }
    public void setSectors(List<SectorItem> sectors) { this.sectors = sectors; }

    public List<StockItem> getTopHoldings() { return topHoldings; }
    public void setTopHoldings(List<StockItem> topHoldings) { this.topHoldings = topHoldings; }

    public String getAttributionText() { return attributionText; }
    public void setAttributionText(String attributionText) { this.attributionText = attributionText; }

    public List<AnnouncementItem> getAnnouncements() { return announcements; }
    public void setAnnouncements(List<AnnouncementItem> announcements) { this.announcements = announcements; }
}
