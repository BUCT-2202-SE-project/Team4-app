package com.example.museum.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class ImageSearchServiceTest {

    @Autowired
    private ImageSearchService imageSearchService;

    @Test
    public void testCalculateSimilarity() {
        // 相同的特征向量，相似度应该为1.0
        String feature1 = "0.1 0.2 0.3 0.4 0.5";
        String feature2 = "0.1 0.2 0.3 0.4 0.5";
        double similarity = imageSearchService.calculateSimilarity(feature1, feature2);
        assertEquals(1.0, similarity, 0.001);
        
        // 不同的特征向量，相似度应该小于1.0
        String feature3 = "0.5 0.4 0.3 0.2 0.1";
        double similarity2 = imageSearchService.calculateSimilarity(feature1, feature3);
        assertTrue(similarity2 < 1.0);
        
        // 正交的特征向量，相似度应该为0.0
        String feature4 = "1.0 0.0 0.0";
        String feature5 = "0.0 1.0 0.0";
        double similarity3 = imageSearchService.calculateSimilarity(feature4, feature5);
        assertEquals(0.0, similarity3, 0.001);
    }
    
    @Test
    public void testFeatureVectorParsing() {
        // 私有方法测试需要通过反射或使用公共方法间接测试
        String featureStr = "0.1 0.2 0.3";
        
        // 通过计算自身相似度（应该为1.0）来测试解析逻辑
        double selfSimilarity = imageSearchService.calculateSimilarity(featureStr, featureStr);
        assertEquals(1.0, selfSimilarity, 0.001);
    }
}
