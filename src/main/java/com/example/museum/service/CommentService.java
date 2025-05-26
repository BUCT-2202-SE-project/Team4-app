package com.example.museum.service;

import com.example.museum.entity.Comment;
import java.util.List;
import java.util.Map;

/**
 * 评论服务接口
 */
public interface CommentService {
    
    /**
     * 根据文物ID获取评论列表
     * @param artifactId 文物ID
     * @return 评论列表
     */
    List<Comment> getCommentsByArtifactId(Integer artifactId);
    
    /**
     * 获取所有评论
     * @return 所有评论
     */
    List<Comment> getAllComments();
    
    /**
     * 添加评论
     * @param comment 评论对象
     * @return 添加的评论
     */
    Comment addComment(Comment comment);
    
    /**
     * 更新评论审核状态
     * @param commentId 评论ID
     * @param reviewStatus 审核状态
     * @return 是否更新成功
     */
    boolean updateReviewStatus(Integer commentId, String reviewStatus);
    
    /**
     * 删除评论
     * @param commentId 评论ID
     * @return 是否删除成功
     */
    boolean deleteComment(Integer commentId);
    
    /**
     * 获取已审核通过的评论和指定用户自己的未审核评论
     * @param artifactId 文物ID
     * @param userId 用户ID
     * @return 评论列表
     */
    List<Comment> getCommentsWithUserPending(Integer artifactId, Integer userId);
    
    /**
     * 编辑评论内容
     * @param commentId 评论ID
     * @param content 新的评论内容
     * @return 编辑后的评论对象，如果评论不存在则返回null
     */
    Comment updateCommentContent(Integer commentId, String content);

    /**
     * 查询用户的所有评论，包括相关的文物信息
     * @param userId 用户ID
     * @return 用户评论列表，包含文物名称和图片
     */
    List<Map<String, Object>> findUserCommentsWithArtifactInfo(Integer userId);
}