package com.example.museum.controller;

import com.example.museum.entity.Comment;
import com.example.museum.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 评论控制器
 */
@RestController
@RequestMapping("/api/comments")
@CrossOrigin
public class CommentController {

    private final CommentService commentService;

    @Autowired
    public CommentController(CommentService commentService) {
        this.commentService = commentService;
    }

    /**
     * 根据文物ID获取评论列表，包含当前用户的未审核评论
     * @param artifactId 文物ID
     * @param userId 当前用户ID（可选）
     * @return 评论列表
     */
    @GetMapping
    public ResponseEntity<List<Comment>> getComments(
            @RequestParam(required = false) Integer artifactId,
            @RequestParam(required = false) Integer userId) {
            
        // 如果提供了artifactId，则返回该文物的评论（包括当前用户的未审核评论）
        if (artifactId != null) {
            List<Comment> comments = userId != null 
                ? commentService.getCommentsWithUserPending(artifactId, userId)
                : commentService.getCommentsByArtifactId(artifactId);
            return ResponseEntity.ok(comments);
        } else {
            List<Comment> allComments = commentService.getAllComments();
            return ResponseEntity.ok(allComments);
        }
    }

    /**
     * 添加评论
     * @param comment 评论对象
     * @return 添加的评论
     */
    @PostMapping
    public ResponseEntity<Comment> addComment(@RequestBody Comment comment) {
        Comment addedComment = commentService.addComment(comment);
        return new ResponseEntity<>(addedComment, HttpStatus.CREATED);
    }

    /**
     * 更新评论审核状态
     * @param id 评论ID
     * @param status 审核状态
     * @return 操作结果
     */
    @PutMapping("/{id}/status")
    public ResponseEntity<String> updateReviewStatus(@PathVariable("id") Integer id, @RequestParam String status) {
        boolean result = commentService.updateReviewStatus(id, status);
        if (result) {
            return ResponseEntity.ok("评论状态更新成功");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 删除评论
     * @param id 评论ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteComment(@PathVariable("id") Integer id) {
        boolean result = commentService.deleteComment(id);
        if (result) {
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 编辑评论内容
     * @param id 评论ID
     * @param requestBody 请求体，包含新的评论内容
     * @return 更新后的评论
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateComment(@PathVariable("id") Integer id, @RequestBody Map<String, String> requestBody) {
        String content = requestBody.get("content");
        if (content == null || content.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("评论内容不能为空");
        }
        
        Comment updatedComment = commentService.updateCommentContent(id, content.trim());
        if (updatedComment != null) {
            return ResponseEntity.ok(updatedComment);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 获取指定用户的所有评论（包括文物信息）
     * @param userId 用户ID
     * @return 用户评论列表，包含文物名称和图片
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserComments(@PathVariable("userId") Integer userId) {
        List<Map<String, Object>> userComments = commentService.findUserCommentsWithArtifactInfo(userId);
        return ResponseEntity.ok(userComments);
    }
}