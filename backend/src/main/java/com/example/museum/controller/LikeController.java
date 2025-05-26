package com.example.museum.controller;

import com.example.museum.entity.Artifact;
import com.example.museum.entity.Like;
import com.example.museum.service.LikeService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 点赞控制器
 */
@RestController
@RequestMapping("/api")
public class LikeController {
    private static final Logger logger = LoggerFactory.getLogger(LikeController.class);

    @Autowired
    private LikeService likeService;

    /**
     * 获取用户点赞的文物列表
     * 
     * @param userId 用户ID，默认为2（测试用户）
     * @return 点赞的文物列表
     */
    @GetMapping("/user/likes")
    public ResponseEntity<?> getUserLikes(@RequestParam(value = "userId", defaultValue = "2") Integer userId) {
        try {
            logger.info("获取用户点赞列表 - 用户ID: {}", userId);
            List<Artifact> likedArtifacts = likeService.getLikedArtifacts(userId);
            
            // 确保每个文物对象都设置了正确的ID
            likedArtifacts.forEach(artifact -> {
                // 如果id为空，但artifactId不为空，则使用artifactId
                if (artifact.getId() == null && artifact.getArtifactId() != null) {
                    artifact.setId(artifact.getArtifactId());
                }
                // 如果artifactId为空，但id不为空，则使用id
                else if (artifact.getArtifactId() == null && artifact.getId() != null) {
                    artifact.setArtifactId(artifact.getId());
                }
                
                logger.debug("返回点赞文物: id={}, artifactId={}, name={}", 
                             artifact.getId(), artifact.getArtifactId(), artifact.getName());
            });
            
            logger.info("成功获取用户点赞列表，共 {} 条记录", likedArtifacts.size());
            return ResponseEntity.ok(likedArtifacts);
        } catch (Exception e) {
            logger.error("获取用户点赞列表异常", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "获取点赞列表失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 添加点赞
     * 
     * @param requestBody 包含artifactId和userId的请求体
     * @return 操作结果
     */
    @PostMapping("/like/add")
    public ResponseEntity<Map<String, Object>> addLike(@RequestBody Map<String, Integer> requestBody) {
        Integer artifactId = requestBody.get("artifactId");
        // 默认使用userId=2进行测试
        Integer userId = requestBody.getOrDefault("userId", 2);

        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("添加点赞 - 用户ID: {}, 文物ID: {}", userId, artifactId);
            
            if (artifactId == null) {
                logger.warn("添加点赞失败 - 文物ID为空");
                response.put("success", false);
                response.put("message", "文物ID不能为空");
                return ResponseEntity.badRequest().body(response);
            }

            boolean result = likeService.addLike(userId, artifactId);
            
            if (result) {
                logger.info("点赞成功");
                response.put("success", true);
                response.put("message", "点赞成功");
            } else {
                logger.warn("点赞失败，可能已经点赞过该文物");
                response.put("success", false);
                response.put("message", "点赞失败，可能已经点赞过该文物");
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("添加点赞异常", e);
            response.put("success", false);
            response.put("message", "添加点赞失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 取消点赞
     * 
     * @param requestBody 包含artifactId和userId的请求体
     * @return 操作结果
     */
    @PostMapping("/like/remove")
    public ResponseEntity<Map<String, Object>> removeLike(@RequestBody Map<String, Integer> requestBody) {
        Integer artifactId = requestBody.get("artifactId");
        // 默认使用userId=2进行测试
        Integer userId = requestBody.getOrDefault("userId", 2);

        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("取消点赞 - 用户ID: {}, 文物ID: {}", userId, artifactId);
            
            if (artifactId == null) {
                logger.warn("取消点赞失败 - 文物ID为空");
                response.put("success", false);
                response.put("message", "文物ID不能为空");
                return ResponseEntity.badRequest().body(response);
            }

            boolean result = likeService.removeLike(userId, artifactId);
            
            if (result) {
                logger.info("取消点赞成功");
                response.put("success", true);
                response.put("message", "取消点赞成功");
            } else {
                logger.warn("取消点赞失败，可能未点赞该文物");
                response.put("success", false);
                response.put("message", "取消点赞失败，可能未点赞该文物");
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("取消点赞异常", e);
            response.put("success", false);
            response.put("message", "取消点赞失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 检查用户是否已点赞某文物
     * 
     * @param artifactId 文物ID
     * @param userId 用户ID，默认为2（测试用户）
     * @return 是否已点赞
     */
    @GetMapping("/like/check")
    public ResponseEntity<Map<String, Object>> checkLike(
            @RequestParam Integer artifactId,
            @RequestParam(value = "userId", defaultValue = "2") Integer userId) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("检查用户是否点赞 - 用户ID: {}, 文物ID: {}", userId, artifactId);
            boolean hasLiked = likeService.hasLiked(userId, artifactId);
            
            logger.info("检查结果: {}", hasLiked);
            response.put("success", true);
            response.put("hasLiked", hasLiked);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("检查用户点赞状态异常", e);
            response.put("success", false);
            response.put("message", "检查点赞状态失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 获取文物的点赞数量
     * 
     * @param artifactId 文物ID
     * @return 点赞数量
     */
    @GetMapping("/artifacts/likes/{artifactId}")
    public ResponseEntity<Map<String, Object>> getArtifactLikes(@PathVariable Integer artifactId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("获取文物点赞数 - 文物ID: {}", artifactId);
            int likesCount = likeService.getLikesCount(artifactId);
            
            logger.info("文物点赞数: {}", likesCount);
            response.put("success", true);
            response.put("data", likesCount);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("获取文物点赞数异常", e);
            response.put("success", false);
            response.put("message", "获取点赞数失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}