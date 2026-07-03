package com.example.fundresearch.dto;

import java.util.List;

/**
 * 标签树节点 DTO（树形结构）
 */
public class TagTreeNodeDTO {

    private Long id;
    private String name;
    private String dimension;
    private Long parentId;
    private List<TagTreeNodeDTO> children;

    public TagTreeNodeDTO() {}

    public TagTreeNodeDTO(Long id, String name, String dimension, Long parentId) {
        this.id = id;
        this.name = name;
        this.dimension = dimension;
        this.parentId = parentId;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDimension() { return dimension; }
    public void setDimension(String dimension) { this.dimension = dimension; }

    public Long getParentId() { return parentId; }
    public void setParentId(Long parentId) { this.parentId = parentId; }

    public List<TagTreeNodeDTO> getChildren() { return children; }
    public void setChildren(List<TagTreeNodeDTO> children) { this.children = children; }
}
