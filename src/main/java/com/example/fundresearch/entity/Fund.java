package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 基金基本信息表 fund_info
 */
@Data
@TableName("fund_info")
public class Fund {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String code;

    private String name;

    /** 基金类型：股票型/混合型/债券型/货币型/指数型 */
    private String type;

    /** 规模（亿元） */
    private BigDecimal scale;

    /** 成立日期 */
    private LocalDate establishDate;

    /** 所属公司ID */
    private Long companyId;

    /** 基金经理ID */
    private Long managerId;

    /** 风险等级 */
    private String riskLevel;

    /** 跟踪指数 */
    private String benchmark;

    /** 业绩归因文本（静态） */
    private String attributionText;
}
