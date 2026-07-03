package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;

/**
 * 基金-标签关联表 fund_tag（复合主键：fund_id + tag_id）
 */
@Data
@TableName("fund_tag")
public class FundTagRelation implements Serializable {

    private Long fundId;

    private Long tagId;

    // 注意：复合主键实体不能直接使用 BaseMapper 的 insert/deleteById 等默认方法。
    // 当前仅用于自定义查询（findFundIdsByAllTags），不影响功能。
}


