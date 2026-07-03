package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 基金前十大重仓股表 fund_stock
 */
@Data
@TableName("fund_stock")
public class FundStock {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long fundId;

    /** 股票名称 */
    private String stockName;

    /** 占比(%) */
    private BigDecimal ratio;
}
