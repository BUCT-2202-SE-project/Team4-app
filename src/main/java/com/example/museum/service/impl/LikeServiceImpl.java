package com.example.museum.service.impl;

import com.example.museum.entity.Artifact;
import com.example.museum.entity.Like;
import com.example.museum.mapper.LikeMapper;
import com.example.museum.service.LikeService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

/**
 * 点赞服务实现类
 */
@Service
public class LikeServiceImpl implements LikeService {
    private static final Logger logger = LoggerFactory.getLogger(LikeServiceImpl.class);

    @Autowired
    private LikeMapper likeMapper;

    @Override
    public List<Like> getUserLikes(Integer userId) {
        logger.info("获取用户点赞列表 - 用户ID: {}", userId);
        try {
            return likeMapper.getLikesByUserId(userId);
        } catch (Exception e) {
            logger.error("获取用户点赞列表失败", e);
            return Collections.emptyList();
        }
    }

    @Override
    public List<Artifact> getLikedArtifacts(Integer userId) {
        logger.info("获取用户点赞文物 - 用户ID: {}", userId);
        try {
            return likeMapper.getLikedArtifactsByUserId(userId);
        } catch (Exception e) {
            logger.error("获取用户点赞文物失败", e);
            return Collections.emptyList();
        }
    }

    @Override
    @Transactional
    public boolean addLike(Integer userId, Integer artifactId) {
        logger.info("添加点赞 - 用户ID: {}, 文物ID: {}", userId, artifactId);
        try {
            // 先检查是否已点赞
            if (hasLiked(userId, artifactId)) {
                logger.info("用户已点赞该文物，无需重复点赞");
                return false; // 已经点赞过了，不能重复点赞
            }

            // 添加点赞记录
            int result = likeMapper.addLike(userId, artifactId);
            if (result > 0) {
                // 直接增加文物的点赞数，而不是重新统计
                likeMapper.incrementArtifactLikes(artifactId);
                logger.info("点赞成功，文物点赞数已增加");
                return true;
            }
            logger.warn("点赞失败，影响行数为0");
            return false;
        } catch (Exception e) {
            logger.error("添加点赞异常", e);
            return false;
        }
    }

    @Override
    @Transactional
    public boolean removeLike(Integer userId, Integer artifactId) {
        logger.info("取消点赞 - 用户ID: {}, 文物ID: {}", userId, artifactId);
        try {
            // 检查是否已点赞
            if (!hasLiked(userId, artifactId)) {
                logger.info("用户未点赞该文物，无法取消");
                return false; // 没有点赞过，无法取消
            }

            // 删除点赞记录
            int result = likeMapper.removeLike(userId, artifactId);
            if (result > 0) {
                // 直接减少文物的点赞数，而不是重新统计
                likeMapper.decrementArtifactLikes(artifactId);
                logger.info("取消点赞成功，文物点赞数已减少");
                return true;
            }
            logger.warn("取消点赞失败，影响行数为0");
            return false;
        } catch (Exception e) {
            logger.error("取消点赞异常", e);
            return false;
        }
    }

    @Override
    public boolean hasLiked(Integer userId, Integer artifactId) {
        try {
            boolean result = likeMapper.checkLikeExists(userId, artifactId) > 0;
            logger.info("检查用户是否点赞 - 用户ID: {}, 文物ID: {}, 结果: {}", userId, artifactId, result);
            return result;
        } catch (Exception e) {
            logger.error("检查用户点赞状态异常", e);
            return false;
        }
    }

    @Override
    public int getLikesCount(Integer artifactId) {
        logger.info("获取文物点赞数 - 文物ID: {}", artifactId);
        try {
            // 查询文物的点赞数量
            return likeMapper.getArtifactLikesCount(artifactId);
        } catch (Exception e) {
            logger.error("获取文物点赞数异常", e);
            return 0;
        }
    }
}