package com.example.museum.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import javax.persistence.*;

@Entity
@Table(name = "artifact")
public class Artifact {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "artifact_id")
    private Integer id;
    
    private String name;
    
    @Column(name = "era")
    private String era; 
    
    private String type;
    
    private String museum;
    
    private String description;
    
    @Column(name = "image_url")
    private String imageUrl;
    
    private Integer likes;
    
    @Column(name = "feature")
    @JsonIgnore
    private String feature;
    
    // 非持久化字段，用于返回相似度
    @Transient
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String similarity;

    // 构造函数
    public Artifact() {
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEra() {
        return era;
    }

    public void setEra(String era) {
        this.era = era;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getMuseum() {
        return museum;
    }

    public void setMuseum(String museum) {
        this.museum = museum;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Integer getLikes() {
        return likes;
    }

    public void setLikes(Integer likes) {
        this.likes = likes;
    }

    public String getFeature() {
        return feature;
    }

    public void setFeature(String feature) {
        this.feature = feature;
    }

    @JsonProperty("similarity")
    public String getSimilarity() {
        return similarity;
    }

    public void setSimilarity(String similarity) {
        this.similarity = similarity;
    }

    // 为前端提供年代和类型的字段别名，保持API一致性
    @JsonProperty("dynasty")
    public String getDynasty() {
        return era;
    }
    
    @JsonProperty("category")
    public String getCategory() {
        return type;
    }
    
    // 为前端提供artifactId别名，确保兼容性
    @JsonProperty("artifactId")
    public Integer getArtifactId() {
        return id;  // 返回id字段的值
    }
    
    public void setArtifactId(Integer artifactId) {
        this.id = artifactId;  // 设置id字段的值
    }
    
    // 向后兼容的方法，但使用不同的名称避免冲突
    @JsonIgnore
    public String getFeatures() {
        return feature;
    }
    
    @JsonIgnore
    public void setFeatures(String features) {
        this.feature = features;
    }
    
    @JsonIgnore
    public void setDynasty(String dynasty) {
        this.era = dynasty;
    }
    
    @JsonIgnore
    public void setCategory(String category) {
        this.type = category;
    }
}
