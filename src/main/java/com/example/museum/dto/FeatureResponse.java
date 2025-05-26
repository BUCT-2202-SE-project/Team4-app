package com.example.museum.dto;

import com.example.museum.config.jackson.NumberToDoubleListDeserializer;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * 特征提取响应DTO，用于调试类型问题
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class FeatureResponse {
    
    private static final Logger logger = LoggerFactory.getLogger(FeatureResponse.class);
    
    @JsonProperty("success")
    private boolean success;
    
    @JsonProperty("error")
    private String error;
    
    @JsonProperty("featureValues")
    private List<Object> featureValues;
    
    // 处理后的特征列表
    private List<Double> processedFeatures;
    
    public boolean isSuccess() {
        return success;
    }
    
    public void setSuccess(boolean success) {
        this.success = success;
    }
    
    public String getError() {
        return error;
    }
    
    public void setError(String error) {
        this.error = error;
    }
    
    public List<Object> getFeatureValues() {
        return featureValues;
    }
    
    public void setFeatureValues(List<Object> featureValues) {
        this.featureValues = featureValues;
        
        // 记录接收到的特征值类型
        if (featureValues != null && !featureValues.isEmpty()) {
            Object firstValue = featureValues.get(0);
            logger.info("[Java] 收到特征类型: {}，首元素类型: {}, 值: {}", 
                featureValues.getClass().getName(),
                firstValue != null ? firstValue.getClass().getName() : "null",
                firstValue);
        }
    }
    
    /**
     * 处理特征列表，将各种类型转换为Double
     * @return 处理后的Double列表
     */
    public List<Double> getProcessedFeatures() {
        if (processedFeatures != null) {
            return processedFeatures;
        }
        
        if (featureValues == null || featureValues.isEmpty()) {
            return null;
        }
        
        // 将各种类型转换为Double
        processedFeatures = featureValues.stream()
            .map(value -> {
                if (value instanceof Number) {
                    return ((Number) value).doubleValue();
                } else if (value instanceof String) {
                    try {
                        return Double.parseDouble((String) value);
                    } catch (NumberFormatException e) {
                        logger.error("无法将字符串转换为Double: {}", value);
                        return 0.0;
                    }
                } else {
                    logger.error("未知类型无法转换为Double: {}", 
                        value != null ? value.getClass().getName() : "null");
                    return 0.0;
                }
            })
            .collect(java.util.stream.Collectors.toList());
        
        // 记录处理后类型
        if (!processedFeatures.isEmpty()) {
            logger.info("[Java] 处理后特征类型: {}, 首元素类型: {}, 值: {}",
                processedFeatures.getClass().getName(),
                processedFeatures.get(0).getClass().getName(),
                processedFeatures.get(0));
        }
        
        return processedFeatures;
    }
}
