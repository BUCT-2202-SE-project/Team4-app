package com.example.museum.service.impl;

import com.example.museum.entity.Artifact;
import com.example.museum.entity.ArtifactCollection;
import com.example.museum.mapper.CollectionMapper;
import com.example.museum.repository.CollectionRepository;
import com.example.museum.service.CollectionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 收藏服务实现类
 */
@Service
public class CollectionServiceImpl implements CollectionService {

    // 添加logger定义
    private static final Logger logger = LoggerFactory.getLogger(CollectionServiceImpl.class);

    @Autowired
    private CollectionRepository collectionRepository;
    
    // 添加CollectionMapper字段声明
    private final CollectionMapper collectionMapper;

    @Autowired
    public CollectionServiceImpl(CollectionMapper collectionMapper) {
        this.collectionMapper = collectionMapper;
    }

    /**
     * 添加收藏
     * 
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 收藏对象
     */
    @Override
    public ArtifactCollection addCollection(Integer userId, Integer artifactId) {
        // 先检查是否已经收藏
        if (isCollected(userId, artifactId)) {
            // 如果已收藏，返回现有记录
            return collectionRepository.findByUserIdAndArtifactId(userId, artifactId)
                .orElseGet(() -> {
                    // 理论上不会执行到这里，因为isCollected已经确认存在
                    ArtifactCollection newCollection = new ArtifactCollection();
                    newCollection.setUserId(userId);
                    newCollection.setArtifactId(artifactId);
                    newCollection.setCreateTime(LocalDateTime.now());
                    return newCollection;
                });
        }

        // 创建新的收藏记录
        ArtifactCollection collection = new ArtifactCollection();
        collection.setUserId(userId);
        collection.setArtifactId(artifactId);
        collection.setCreateTime(LocalDateTime.now());
        
        // 保存并返回收藏对象
        return collectionRepository.save(collection);
    }

    /**
     * 取消收藏
     * 
     * @param userId 用户ID
     * @param artifactId 文物ID  
     * @return 是否取消成功
     */
    @Override
    public boolean removeCollection(Integer userId, Integer artifactId) {
        try {
            // 删除收藏记录
            int rows = collectionMapper.delete(userId, artifactId);
            
            // 返回是否成功删除记录
            return rows > 0;
        } catch (Exception e) {
            // 记录异常并返回失败
            logger.error("取消收藏失败: ", e);
            return false;
        }
    }

    @Override
    public List<Artifact> getUserCollections(Integer userId) {
        return collectionMapper.getCollectedArtifacts(userId);
    }

    @Override
    public boolean isCollected(Integer userId, Integer artifactId) {
        // 参数验证
        if (userId == null || userId <= 0 || artifactId == null || artifactId <= 0) {
            logger.warn("检查收藏状态参数无效: userId={}, artifactId={}", userId, artifactId);
            return false; // 无效参数，返回未收藏状态
        }
        
        try {
            // 使用repository方法检查是否存在收藏记录
            boolean collected = collectionRepository.existsByUserIdAndArtifactId(userId, artifactId);
            logger.info("检查收藏状态: userId={}, artifactId={}, 结果={}", userId, artifactId, collected);
            return collected;
        } catch (Exception e) {
            logger.error("检查收藏状态异常", e);
            return false; // 发生异常，返回未收藏状态
        }
    }
}