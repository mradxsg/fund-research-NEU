package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;

/**
 * 组合持仓明细表 portfolio_item（复合主键：portfolio_id + fund_id）
 */
@Data
@TableName("portfolio_item")
public class PortfolioItem implements Serializable {

    private Long portfolioId;

    private Long fundId;

    // 注意：复合主键实体不能直接使用 BaseMapper 的 insert/deleteById 等默认方法。
    // 如需增删改，请在 Mapper 中自定义 XML 语句。
}


