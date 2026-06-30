package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * 基金经理表 fund_manager
 */
@Data
@TableName("fund_manager")
public class FundManager {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private Integer experienceYears;
}
