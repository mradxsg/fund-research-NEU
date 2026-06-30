package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 基金净值历史表 fund_nav
 */
@Data
@TableName("fund_nav")
public class FundNav {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long fundId;

    /** 净值日期（MySQL保留字，需要显式指定列名并加反引号） */
    @TableField("`date`")
    private LocalDate date;

    /** 单位净值 */
    private BigDecimal unitNav;

    /** 累计净值 */
    private BigDecimal accumNav;

    /** 日涨跌幅(%) */
    private BigDecimal dailyReturn;
}



