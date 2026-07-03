package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;

/**
 * 基金公告表 fund_announcement
 */
@Data
@TableName("fund_announcement")
public class FundAnnouncement {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long fundId;

    /** 公告标题 */
    private String title;

    /** 公告日期 */
    private LocalDate publishDate;
}
