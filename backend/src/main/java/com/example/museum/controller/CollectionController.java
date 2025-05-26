package com.example.museum.controller;

import com.example.museum.dto.ApiResponse;
import com.example.museum.entity.Artifact;
import com.example.museum.entity.ArtifactCollection; // 修改引入的实体类
import com.example.museum.service.CollectionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin
public class CollectionController {

    private static final Logger logger = LoggerFactory.getLogger(CollectionController.class);

    @Autowired
    private CollectionService collectionService;

    /**
     * 获取用户收藏列表
     * @param userId 用户ID，从请求参数中获取
     * @return 收藏列表响应
     */
    @GetMapping("/user/collections")
    public ApiResponse<List<Artifact>> getUserCollections(@RequestParam Integer userId) {
        logger.info("获取用户收藏列表请求，用户ID: {}", userId);
        
        try {
            if (userId == null || userId <= 0) {
                return ApiResponse.error("无效的用户ID");
            }
            
            List<Artifact> collections = collectionService.getUserCollections(userId);
            return ApiResponse.success("获取用户收藏成功", collections);
        } catch (Exception e) {
            logger.error("获取用户收藏失败", e);
            return ApiResponse.error("获取用户收藏失败: " + e.getMessage());
        }
    }

    /**
     * 添加收藏
     * @param requestBody 包含用户ID和文物ID的请求体
     * @return 添加结果响应
     */
    @PostMapping("/collection/add")
    public ApiResponse<ArtifactCollection> addCollection(@RequestBody Map<String, Object> requestBody) { // 修改返回类型
        // 从请求体中获取用户ID和文物ID
        Integer userId = (Integer) requestBody.get("userId");
        Integer artifactId = (Integer) requestBody.get("artifactId");
        
        logger.info("添加收藏请求，用户ID: {}, 文物ID: {}", userId, artifactId);
        
        try {
            // 参数验证
            if (userId == null || userId <= 0) {
                return ApiResponse.error("无效的用户ID");
            }
            
            if (artifactId == null || artifactId <= 0) {
                return ApiResponse.error("无效的文物ID");
            }
            
            ArtifactCollection collection = collectionService.addCollection(userId, artifactId); // 修改返回类型
            return ApiResponse.success("收藏成功", collection);
        } catch (Exception e) {
            logger.error("添加收藏失败", e);
            return ApiResponse.error("添加收藏失败: " + e.getMessage());
        }
    }

    /**
     * 取消收藏
     * @param requestBody 包含用户ID和文物ID的请求体
     * @return 取消结果响应
     */
    @PostMapping("/collection/remove")
    public ApiResponse<Boolean> removeCollection(@RequestBody Map<String, Object> requestBody) {
        // 从请求体中获取用户ID和文物ID
        Integer userId = (Integer) requestBody.get("userId");
        Integer artifactId = (Integer) requestBody.get("artifactId");
        
        logger.info("取消收藏请求，用户ID: {}, 文物ID: {}", userId, artifactId);
        
        try {
            // 参数验证
            if (userId == null || userId <= 0) {
                return ApiResponse.error("无效的用户ID");
            }
            
            if (artifactId == null || artifactId <= 0) {
                return ApiResponse.error("无效的文物ID");
            }
            
            boolean result = collectionService.removeCollection(userId, artifactId);
            return ApiResponse.success("取消收藏成功", result);
        } catch (Exception e) {
            logger.error("取消收藏失败", e);
            return ApiResponse.error("取消收藏失败: " + e.getMessage());
        }
    }

    /**
     * 检查是否已收藏
     * @param artifactId 文物ID
     * @param userId 用户ID，从查询参数获取
     * @return 检查结果响应
     */
    @GetMapping("/collection/check")
    public ApiResponse<Boolean> checkCollection(
            @RequestParam Integer artifactId, 
            @RequestParam(required = false) Integer userId) {
        
        logger.info("检查收藏状态请求，用户ID: {}, 文物ID: {}", userId, artifactId);
        
        try {
            // 参数验证
            if (artifactId == null || artifactId <= 0) {
                return ApiResponse.error("无效的文物ID");
            }
            
            // 如果没有提供用户ID，从用户服务获取当前用户ID
            if (userId == null || userId <= 0) {
                // 这里可以从用户服务或认证上下文获取当前用户ID
                // 如果没有认证机制，可以使用默认用户（例如访客用户ID=0）
                userId = 1; // 临时使用默认用户ID，实际应用中应该从认证上下文获取
                logger.info("未提供用户ID，使用默认用户ID: {}", userId);
            }
            
            boolean isCollected = collectionService.isCollected(userId, artifactId);
            logger.info("检查收藏状态结果: userId={}, artifactId={}, isCollected={}", 
                    userId, artifactId, isCollected);
            
            return ApiResponse.success("检查收藏状态成功", isCollected);
        } catch (Exception e) {
            logger.error("检查收藏状态失败", e);
            return ApiResponse.error("检查收藏状态失败: " + e.getMessage());
        }
    }
}