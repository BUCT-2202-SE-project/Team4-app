package com.example.museum.utils;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * 特征向量工具类
 */
public class FeatureUtils {
    
    private static final ObjectMapper objectMapper = new ObjectMapper();
    
    /**
     * 将特征向量转换为数据库存储的字符串
     * @param features 特征向量
     * @return 字符串表示
     */
    public static String featuresToString(double[] features) {
        try {
            return objectMapper.writeValueAsString(features);
        } catch (Exception e) {
            throw new RuntimeException("特征向量转字符串失败", e);
        }
    }
    
    /**
     * 将数据库中的字符串转回特征向量
     * @param featuresString 特征向量的字符串表示
     * @return 特征向量数组
     */
    public static double[] stringToFeatures(String featuresString) {
        try {
            return objectMapper.readValue(featuresString, double[].class);
        } catch (Exception e) {
            throw new RuntimeException("字符串转特征向量失败", e);
        }
    }
    
    /**
     * 计算两个特征向量间的余弦相似度
     * @param features1 第一个特征向量
     * @param features2 第二个特征向量
     * @return 余弦相似度 (1表示完全相似，0表示不相似)
     */
    public static double calculateCosineSimilarity(double[] features1, double[] features2) {
        if (features1.length != features2.length) {
            throw new IllegalArgumentException("特征向量长度不一致");
        }
        
        double dotProduct = 0.0;
        for (int i = 0; i < features1.length; i++) {
            dotProduct += features1[i] * features2[i];
        }
        
        // 由于特征向量已经通过L2归一化，所以不需要再除以向量模长
        return dotProduct;
    }
}
