package com.example.museum.controller;

import com.example.museum.dto.ApiResponse;
import com.example.museum.entity.Artifact;
import com.example.museum.service.ImageSearchService;
import com.example.museum.service.ArtifactService;
import com.example.museum.service.FeatureExtractionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

/**
 * 图像搜索控制器
 */
@RestController
@RequestMapping("/api")
@CrossOrigin
public class ImageSearchController {
    
    private static final Logger logger = LoggerFactory.getLogger(ImageSearchController.class);
    
    @Autowired
    private ImageSearchService imageSearchService;

    @Autowired
    private ArtifactService artifactService;
    
    @Autowired
    private FeatureExtractionService featureExtractionService;
    
    @Value("${museum.temp.path:temp}")
    private String tempPath;
    
    /**
     * 以图搜图API端点
     * @param imageData 图片二进制数据
     * @param limit 限制结果数量，默认为10
     * @return 搜索结果
     */
    @PostMapping(value = "/artifacts/search/image", consumes = MediaType.IMAGE_JPEG_VALUE)
    public ApiResponse<List<Artifact>> searchByImage(
            @RequestBody byte[] imageData,
            @RequestParam(required = false, defaultValue = "10") int limit) {
        
        logger.info("接收到图像搜索请求，图像大小: {} 字节，限制结果数量: {}", imageData.length, limit);
        
        try {
            if (imageData.length == 0) {
                return ApiResponse.error("图像数据为空");
            }
            
            // 调用服务层进行搜索
            List<Artifact> results = imageSearchService.searchSimilarArtifacts(imageData, limit);
            
            // 日志记录搜索结果及相似度
            if (!results.isEmpty()) {
                for (Artifact artifact : results) {
                    logger.debug("返回给前端 - 文物ID: {}, 名称: {}, 相似度: {}", 
                        artifact.getId(), artifact.getName(), artifact.getSimilarity());
                }
            }
            
            if (results.isEmpty()) {
                return ApiResponse.success("未找到相似文物", results);
            }
            
            return ApiResponse.success("搜索成功", results);
            
        } catch (Exception e) {
            logger.error("图像搜索处理失败", e);
            return ApiResponse.error("图像搜索失败: " + e.getMessage());
        }
    }

    /**
     * 提供备用API端点
     */
    @PostMapping(value = "/search/image", consumes = MediaType.IMAGE_JPEG_VALUE)
    public ApiResponse<List<Artifact>> searchByImageAlternative(
            @RequestBody byte[] imageData,
            @RequestParam(required = false, defaultValue = "10") int limit) {
        // 复用主方法实现
        return searchByImage(imageData, limit);
    }

    /**
     * 上传图片并搜索相似文物
     */
    @PostMapping("/upload")
    public ResponseEntity<?> searchByUploadedImage(
            @RequestParam("image") MultipartFile image,
            @RequestParam(value = "threshold", defaultValue = "0.6") double threshold,
            @RequestParam(value = "maxResults", defaultValue = "10") int maxResults) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 检查服务健康状态
            if (!imageSearchService.isFeatureServiceHealthy()) {
                response.put("success", false);
                response.put("message", "特征提取服务不可用，请稍后再试");
                return ResponseEntity.status(503).body(response);
            }
            
            // 处理图片并查找相似文物
            List<Artifact> similarArtifacts = imageSearchService.searchSimilarArtifacts(image, threshold, maxResults);
            
            response.put("success", true);
            response.put("message", "成功查找到相似文物");
            response.put("data", similarArtifacts);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "查找相似文物失败: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * 通过图片路径查找相似文物
     */
    @GetMapping("/by-path")
    public ResponseEntity<?> searchByImagePath(
            @RequestParam("imagePath") String imagePath,
            @RequestParam(value = "threshold", defaultValue = "0.6") double threshold,
            @RequestParam(value = "maxResults", defaultValue = "10") int maxResults) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 检查服务健康状态
            if (!imageSearchService.isFeatureServiceHealthy()) {
                response.put("success", false);
                response.put("message", "特征提取服务不可用，请稍后再试");
                return ResponseEntity.status(503).body(response);
            }
            
            // 通过路径查找相似文物
            List<Artifact> similarArtifacts = imageSearchService.searchSimilarArtifactsByPath(imagePath, threshold, maxResults);
            
            response.put("success", true);
            response.put("message", "成功查找到相似文物");
            response.put("data", similarArtifacts);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "查找相似文物失败: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * 健康检查端点
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        boolean isHealthy = imageSearchService.isFeatureServiceHealthy();
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", isHealthy ? "ok" : "error");
        response.put("message", isHealthy ? "服务正常" : "特征提取服务不可用");
        
        return ResponseEntity.ok(response);
    }
}
