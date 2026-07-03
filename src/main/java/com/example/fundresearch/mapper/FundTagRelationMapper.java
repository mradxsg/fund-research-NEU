package com.example.fundresearch.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.fundresearch.entity.FundTagRelation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface FundTagRelationMapper extends BaseMapper<FundTagRelation> {

    /**
     * 查找拥有全部指定标签的基金ID（标签交集查询）
     */
    @Select("<script>"
            + "SELECT fund_id FROM fund_tag WHERE tag_id IN "
            + "<foreach collection='tagIds' item='tagId' open='(' separator=',' close=')'>#{tagId}</foreach>"
            + " GROUP BY fund_id HAVING COUNT(DISTINCT tag_id) = #{tagCount}"
            + "</script>")
    List<Long> findFundIdsByAllTags(@Param("tagIds") List<Long> tagIds, @Param("tagCount") long tagCount);
}
