package com.example.museum.controller;

import com.example.museum.dto.ApiResponse;
import com.example.museum.entity.Artifact;
import com.example.museum.service.ArtifactService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/artifacts")
@CrossOrigin
public class ArtifactController {
    
    private static final Logger logger = LoggerFactory.getLogger(ArtifactController.class);
    
    @Autowired
    private ArtifactService artifactService;
    
    /**
     * 获取所有文物 - 修改为直接返回数组以兼容前端
     */
    @GetMapping
    public List<Artifact> getAllArtifacts() {
        logger.info("获取所有文物请求");
        try {
            return artifactService.getAllArtifacts();
        } catch (Exception e) {
            logger.error("获取文物列表失败", e);
            // 由于需要返回数组，错误情况下返回空数组
            return Collections.emptyList();
        }
    }
    
    /**
     * 根据ID获取文物
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getArtifactById(@PathVariable Integer id) {
        logger.info("获取文物详情请求，ID: {}", id);
        
        try {
            // 修改为直接接收Artifact对象，而非Optional<Artifact>
            Artifact artifact = artifactService.getArtifactById(id);
            
            if (artifact != null) {
                // 直接返回文物对象
                return ResponseEntity.ok(artifact);
            } else {
                // 返回404状态码
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            logger.error("获取文物详情失败", e);
            // 修改：使用静态工厂方法而不是构造函数
            return ResponseEntity.internalServerError().body(
                ApiResponse.error("获取文物详情失败: " + e.getMessage())
            );
        }
    }
    
    /**
     * 根据名称搜索文物
     */
    @GetMapping("/search")
    public List<Artifact> searchArtifacts(@RequestParam String name) {
        logger.info("搜索文物请求，名称关键词: {}", name);
        
        try {
            return artifactService.searchArtifactsByName(name);
        } catch (Exception e) {
            logger.error("搜索文物失败", e);
            // 由于需要返回数组，错误情况下返回空数组
            return Collections.emptyList();
        }
    }
    
    /**
     * 根据年代获取文物
     */
    @GetMapping("/era/{era}")
    public List<Artifact> getArtifactsByEra(@PathVariable String era) {
        logger.info("按年代获取文物请求，年代: {}", era);
        
        try {
            return artifactService.getArtifactsByEra(era);
        } catch (Exception e) {
            logger.error("按年代获取文物失败", e);
            return Collections.emptyList();
        }
    }
    
    /**
     * 根据类型获取文物
     */
    @GetMapping("/type/{type}")
    public List<Artifact> getArtifactsByType(@PathVariable String type) {
        logger.info("按类型获取文物请求，类型: {}", type);
        
        try {
            return artifactService.getArtifactsByType(type);
        } catch (Exception e) {
            logger.error("按类型获取文物失败", e);
            return Collections.emptyList();
        }
    }
    
    /**
     * 根据博物馆获取文物
     */
    @GetMapping("/museum/{museum}")
    public List<Artifact> getArtifactsByMuseum(@PathVariable String museum) {
        logger.info("按博物馆获取文物请求，博物馆: {}", museum);
        
        try {
            return artifactService.getArtifactsByMuseum(museum);
        } catch (Exception e) {
            logger.error("按博物馆获取文物失败", e);
            return Collections.emptyList();
        }
    }
    
    /**
     * 获取文物点赞数
     */
    @GetMapping("/likes/{id}")
    public ResponseEntity<?> getArtifactLikes(@PathVariable Integer id) {
        logger.info("获取文物点赞数请求，ID: {}", id);
        
        try {
            Integer likes = artifactService.getLikes(id);
            
            if (likes != null) {
                return ResponseEntity.ok(likes);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            logger.error("获取点赞数失败", e);
            // 修改：使用静态工厂方法而不是构造函数
            return ResponseEntity.internalServerError().body(
                ApiResponse.error("获取点赞数失败: " + e.getMessage())
            );
        }
    }
}