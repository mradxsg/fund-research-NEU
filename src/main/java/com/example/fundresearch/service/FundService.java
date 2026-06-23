package com.example.fundresearch.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.fundresearch.entity.Fund;
import java.util.List;

public interface FundService {
    /**
     * 按关键字和标签筛选基金（分页）
     * @param keyword 代码/名称关键字（可空）
     * @param tagIds  标签ID列表（可空）
     * @param page    页码
     * @param size    每页条数
     * @return 分页结果
     */
    IPage<Fund> queryFunds(String keyword, List<Long> tagIds, int page, int size);
}


