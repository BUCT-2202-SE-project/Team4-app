package com.example.museum.service;

import com.example.museum.entity.Artifact;
import com.example.museum.repository.ArtifactRepository;
import com.example.museum.utils.FeatureUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class ArtifactService {
    
    private static final Logger logger = LoggerFactory.getLogger(ArtifactService.class);
    
    @Autowired
    private ArtifactRepository artifactRepository;
    
    /**
     * 获取所有文物
     */
    public List<Artifact> getAllArtifacts() {
        return artifactRepository.findAll();
    }
    
    /**
     * 根据ID获取文物
     */
    public Artifact getArtifactById(Integer id) {
        Optional<Artifact> artifactOpt = artifactRepository.findById(id);
        
        // 错误用法 - 直接返回Optional对象
        // return artifactOpt;  // 这会导致类型不匹配错误
        
        // 正确用法1 - 使用orElse提供默认值
        return artifactOpt.orElse(null);  // 如果存在则返回文物，否则返回null

    }
    
    /**
     * 根据名称搜索文物
     */
    public List<Artifact> searchArtifactsByName(String name) {
        return artifactRepository.findByNameContaining(name);
    }
    
    /**
     * 根据年代获取文物
     */
    public List<Artifact> getArtifactsByEra(String era) {
        return artifactRepository.findByEra(era);
    }
    
    /**
     * 根据类型获取文物
     */
    public List<Artifact> getArtifactsByType(String type) {
        return artifactRepository.findByType(type);
    }
    
    /**
     * 根据博物馆获取文物
     */
    public List<Artifact> getArtifactsByMuseum(String museum) {
        return artifactRepository.findByMuseum(museum);
    }
    
    /**
     * 增加文物点赞数
     */
    @Transactional
    public void incrementLikes(Integer id) {
        artifactRepository.incrementLikes(id);
    }
    
    /**
     * 减少文物点赞数
     */
    @Transactional
    public void decrementLikes(Integer id) {
        artifactRepository.decrementLikes(id);
    }
    
    /**
     * 获取文物点赞数
     */
    public Integer getLikes(Integer id) {
        return artifactRepository.getLikes(id);
    }
    
    /**
     * 查找相似文物
     */
    public List<Artifact> findSimilarArtifacts(String featureJson, double threshold, int maxResults) {
        double[] queryFeature = FeatureUtils.stringToFeatures(featureJson);
        List<Artifact> allArtifacts = artifactRepository.findAll();
        
        List<ArtifactSimilarity> similarArtifacts = new ArrayList<>();
        
        for (Artifact artifact : allArtifacts) {
            if (artifact.getFeature() == null || artifact.getFeature().isEmpty()) {
                continue;
            }
            
            double[] artifactFeature = FeatureUtils.stringToFeatures(artifact.getFeature());
            double similarity = FeatureUtils.calculateCosineSimilarity(queryFeature, artifactFeature);
            
            if (similarity >= threshold) {
                ArtifactSimilarity artifactSimilarity = new ArtifactSimilarity(artifact, similarity);
                similarArtifacts.add(artifactSimilarity);
            }
        }
        
        // 根据相似度排序
        similarArtifacts.sort((a, b) -> Double.compare(b.getSimilarity(), a.getSimilarity()));
        
        // 限制结果数量
        int resultSize = Math.min(maxResults, similarArtifacts.size());
        List<Artifact> result = new ArrayList<>(resultSize);
        
        for (int i = 0; i < resultSize; i++) {
            ArtifactSimilarity artifactSimilarity = similarArtifacts.get(i);
            Artifact artifact = artifactSimilarity.getArtifact();
            
            // 设置相似度
            artifact.setSimilarity(String.valueOf(artifactSimilarity.getSimilarity()));
            result.add(artifact);
        }
        
        return result;
    }
    
    // 内部类，用于存储文物和相似度
    private static class ArtifactSimilarity {
        private final Artifact artifact;
        private final double similarity;
        
        public ArtifactSimilarity(Artifact artifact, double similarity) {
            this.artifact = artifact;
            this.similarity = similarity;
        }
        
        public Artifact getArtifact() {
            return artifact;
        }
        
        public double getSimilarity() {
            return similarity;
        }
    }
}
