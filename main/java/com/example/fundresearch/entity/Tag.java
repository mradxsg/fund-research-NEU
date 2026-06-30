package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * 标签主表 tag（支持多级层级）
 */
@Data
@TableName("tag")
public class Tag {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    /** 适用维度：fund/company/manager */
    private String dimension;

    /** 父标签ID，可空 */
    private Long parentId;
}
