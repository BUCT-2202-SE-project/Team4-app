package com.example.museum.entity;

import java.util.Date;

/**
 * 评论实体类，对应数据库中的comment表
 */
public class Comment {
    private Integer commentId;    // 评论ID
    private String content;       // 评论内容
    private Date publishTime;     // 发布时间
    private Integer userId;       // 用户ID
    private Integer artifactId;   // 文物ID
    private String reviewStatus;  // 审核状态
    
    // 额外添加的非数据库字段，用于前端显示
    private String username;      // 用户名，从user表中获取

    // 无参构造函数
    public Comment() {
    }

    // 带参数的构造函数
    public Comment(Integer commentId, String content, Date publishTime, Integer userId, Integer artifactId, String reviewStatus) {
        this.commentId = commentId;
        this.content = content;
        this.publishTime = publishTime;
        this.userId = userId;
        this.artifactId = artifactId;
        this.reviewStatus = reviewStatus;
    }

    // Getters and Setters
    public Integer getCommentId() {
        return commentId;
    }

    public void setCommentId(Integer commentId) {
        this.commentId = commentId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Date getPublishTime() {
        return publishTime;
    }

    public void setPublishTime(Date publishTime) {
        this.publishTime = publishTime;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getArtifactId() {
        return artifactId;
    }

    public void setArtifactId(Integer artifactId) {
        this.artifactId = artifactId;
    }

    public String getReviewStatus() {
        return reviewStatus;
    }

    public void setReviewStatus(String reviewStatus) {
        this.reviewStatus = reviewStatus;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Override
    public String toString() {
        return "Comment{" +
                "commentId=" + commentId +
                ", content='" + content + '\'' +
                ", publishTime=" + publishTime +
                ", userId=" + userId +
                ", artifactId=" + artifactId +
                ", reviewStatus='" + reviewStatus + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}