package com.example.museum.entity;

import lombok.Getter;
import javax.persistence.*;
import java.time.LocalDateTime;

/**
 * 收藏实体类
 */
@Entity
@Table(name = "collection")
@Getter
public class ArtifactCollection {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "collection_id")
    private Integer id; // 对应数据库中的 collection_id
    
    @Column(name = "user_id")
    private Integer userId; // 对应数据库中的 user_id
    
    @Column(name = "artifact_id")
    private Integer artifactId; // 对应数据库中的 artifact_id
    
    @Column(name = "collect_time")
    private LocalDateTime createTime; // 对应数据库中的 collect_time

    public void setId(Integer id) {
        this.id = id;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public void setArtifactId(Integer artifactId) {
        this.artifactId = artifactId;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    @Override
    public String toString() {
        return "ArtifactCollection{" +
               "id=" + id +
               ", userId=" + userId +
               ", artifactId=" + artifactId +
               ", createTime=" + createTime +
               '}';
    }
}