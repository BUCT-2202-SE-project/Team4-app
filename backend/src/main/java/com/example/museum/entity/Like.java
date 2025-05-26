package com.example.museum.entity;

import lombok.Data;

/**
 * 点赞实体类，对应数据库likes表
 */
@Data
public class Like {
    private Integer likeId;    // 点赞记录ID(主键)
    private Integer userId;    // 用户ID
    private Integer artifactId; // 文物ID
    
    // 扩展字段，用于前端展示，不直接对应数据库字段
    private String artifactName;
    private String artifactImageUrl;
}