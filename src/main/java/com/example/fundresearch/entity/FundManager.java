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
    private Long id;
    private String name;
    private Integer experienceYears;

    private String contact;   // 联系方式
    private String bio;       // 简介

}
