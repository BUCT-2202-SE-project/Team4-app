package com.example.museum.service.impl;

import com.example.museum.entity.Comment;
import com.example.museum.mapper.CommentMapper;
import com.example.museum.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 评论服务实现类
 */
@Service
public class CommentServiceImpl implements CommentService {

    private final CommentMapper commentMapper;

    @Autowired
    public CommentServiceImpl(CommentMapper commentMapper) {
        this.commentMapper = commentMapper;
    }

    @Override
    public List<Comment> getCommentsByArtifactId(Integer artifactId) {
        return commentMapper.findByArtifactId(artifactId);
    }

    @Override
    public List<Comment> getAllComments() {
        return commentMapper.findAll();
    }

    @Override
    public Comment addComment(Comment comment) {
        // 设置发布时间为当前时间
        if (comment.getPublishTime() == null) {
            comment.setPublishTime(new Date());
        }
        
        // 设置默认审核状态为"未通过"，等待管理员审核
        if (comment.getReviewStatus() == null) {
            comment.setReviewStatus("未通过");
        }
        
        // 插入评论到数据库
        commentMapper.insert(comment);
        return comment;
    }

    @Override
    public boolean updateReviewStatus(Integer commentId, String reviewStatus) {
        return commentMapper.updateReviewStatus(commentId, reviewStatus) > 0;
    }

    @Override
    public boolean deleteComment(Integer commentId) {
        return commentMapper.deleteById(commentId) > 0;
    }
    
    @Override
    public List<Comment> getCommentsWithUserPending(Integer artifactId, Integer userId) {
        // 查询该文物下已审核的评论和指定用户的未审核评论
        return commentMapper.findApprovedAndUserPending(artifactId, userId);
    }

    @Override
    public Comment updateCommentContent(Integer commentId, String content) {
        // 确认评论存在
        Comment existingComment = commentMapper.findById(commentId);
        if (existingComment == null) {
            return null; // 评论不存在
        }
        
        // 更新评论内容，并将状态设置为"未通过"以便重新审核
        int updated = commentMapper.updateContent(commentId, content);
        if (updated > 0) {
            // 获取更新后的评论
            return commentMapper.findById(commentId);
        }
        return null;
    }
    
    /**
     * 查询用户的所有评论，包括相关的文物信息
     * 
     * @param userId 用户ID
     * @return 用户评论列表，包含文物名称和图片
     */
    @Override
    public List<Map<String, Object>> findUserCommentsWithArtifactInfo(Integer userId) {
        return commentMapper.findUserCommentsWithArtifactInfo(userId);
    }
}