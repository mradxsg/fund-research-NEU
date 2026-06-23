package com.example.fundresearch.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.fundresearch.entity.Fund;
import com.example.fundresearch.mapper.FundMapper;
import com.example.fundresearch.service.FundService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class FundServiceImpl extends ServiceImpl<FundMapper, Fund> implements FundService {

    @Override
    public IPage<Fund> queryFunds(String keyword, List<Long> tagIds, int page, int size) {
        Page<Fund> p = new Page<>(page, size);
        LambdaQueryWrapper<Fund> wrapper = new LambdaQueryWrapper<>();

        // 关键字搜索：代码或名称模糊匹配
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(Fund::getCode, keyword).or().like(Fund::getName, keyword));
        }

        // 标签筛选（后期实现，现在暂时忽略）
        // 如果需要根据标签筛选，需要关联 fund_tag 表，可使用子查询或 XML 实现
        // 例如：wrapper.inSql(Fund::getId, "SELECT fund_id FROM fund_tag WHERE tag_id IN ("+tagIds+")");
        // 这里先留空，等标签数据插入后再补充

        return this.page(p, wrapper);
    }
}


