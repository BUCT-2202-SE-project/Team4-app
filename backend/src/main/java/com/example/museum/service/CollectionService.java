package com.example.museum.service;

import com.example.museum.entity.Artifact;
import com.example.museum.entity.ArtifactCollection;

import java.util.List;
import java.util.Map;

/**
 * 收藏服务接口
 */
public interface CollectionService {
    
    /**
     * 添加收藏
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 收藏对象
     */
    ArtifactCollection addCollection(Integer userId, Integer artifactId);
    
    /**
     * 取消收藏
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 操作是否成功
     */
    boolean removeCollection(Integer userId, Integer artifactId);
    
    /**
     * 获取用户收藏的文物列表
     * @param userId 用户ID
     * @return 文物列表
     */
    List<Artifact> getUserCollections(Integer userId);
    
    /**
     * 检查用户是否已收藏某文物
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 是否已收藏
     */
    boolean isCollected(Integer userId, Integer artifactId);
}