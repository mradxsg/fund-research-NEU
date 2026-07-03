package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 基金组合表 portfolio
 */
@Data
@TableName("portfolio")
public class Portfolio {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String name;

    private LocalDateTime createdTime;
}
