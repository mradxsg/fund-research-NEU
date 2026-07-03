package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 基金行业配置表 fund_sector
 */
@Data
@TableName("fund_sector")
public class FundSector {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long fundId;

    /** 行业名称 */
    private String sectorName;

    /** 占比(%) */
    private BigDecimal ratio;
}
