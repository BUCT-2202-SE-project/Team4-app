package com.example.museum.service;

import com.example.museum.entity.Artifact;
import com.example.museum.entity.Like;

import java.util.List;
import java.util.Map;

/**
 * 点赞服务接口
 */
public interface LikeService {

    /**
     * 获取用户所有的点赞记录
     *
     * @param userId 用户ID
     * @return 点赞记录列表
     */
    List<Like> getUserLikes(Integer userId);

    /**
     * 获取用户点赞的所有文物
     *
     * @param userId 用户ID
     * @return 文物列表
     */
    List<Artifact> getLikedArtifacts(Integer userId);

    /**
     * 添加点赞
     *
     * @param userId     用户ID
     * @param artifactId 文物ID
     * @return 操作结果
     */
    boolean addLike(Integer userId, Integer artifactId);

    /**
     * 取消点赞
     *
     * @param userId     用户ID
     * @param artifactId 文物ID
     * @return 操作结果
     */
    boolean removeLike(Integer userId, Integer artifactId);

    /**
     * 检查用户是否已点赞某文物
     *
     * @param userId     用户ID
     * @param artifactId 文物ID
     * @return 是否已点赞
     */
    boolean hasLiked(Integer userId, Integer artifactId);

    /**
     * 获取文物的点赞数量
     *
     * @param artifactId 文物ID
     * @return 点赞数量
     */
    int getLikesCount(Integer artifactId);
}