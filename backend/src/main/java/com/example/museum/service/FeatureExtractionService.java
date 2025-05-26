package com.example.museum.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.ejml.simple.SimpleMatrix;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * 与Python特征提取服务通信的服务类
 */
@Service
public class FeatureExtractionService {
    
    private static final Logger logger = LoggerFactory.getLogger(FeatureExtractionService.class);
    
    private final RestTemplate restTemplate;
    
    @Value("${feature.extraction.service.url:http://localhost:5000}")
    private String extractionServiceUrl;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    public FeatureExtractionService() {
        this.restTemplate = new RestTemplate();
    }
    
    @PostConstruct
    public void init() {
        // 应用启动时检查Python服务是否可用
        checkPythonService();
    }
    
    private void checkPythonService() {
        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(
                extractionServiceUrl + "/health", 
                Map.class
            );
            
            if (response.getStatusCode() == HttpStatus.OK && 
                response.getBody() != null && 
                "ok".equals(response.getBody().get("status"))) {
                logger.info("Python特征提取服务运行正常");
            } else {
                logger.warn("Python特征提取服务可能不可用，HTTP状态码: {}", response.getStatusCode());
            }
        } catch (Exception e) {
            logger.error("无法连接到Python特征提取服务，请确保服务正在运行: {}", e.getMessage());
            logger.info("您可以通过运行 d:\\collegelife\\Grade_three_second\\SWE\\backend\\museum\\src\\main\\python\\start_service.bat 启动服务");
        }
    }
    
    /**
     * 调用Python服务提取图像特征
     * @param imagePath 图像文件路径
     * @return 提取的特征向量
     */
    public float[] extractFeatures(String imagePath) {
        logger.info("正在从图像提取特征: " + imagePath);
        
        // 构建请求体
        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("image_path", imagePath);
        
        // 设置请求头
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        
        // 创建HTTP实体
        HttpEntity<Map<String, String>> requestEntity = new HttpEntity<>(requestBody, headers);
        
        try {
            // 发送POST请求到Python服务
            ResponseEntity<String> response = restTemplate.exchange(
                extractionServiceUrl + "/extract",
                HttpMethod.POST,
                requestEntity,
                String.class  // 获取原始字符串响应
            );
            
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                String responseBody = response.getBody();
                
                // 记录接收到的原始JSON
                // 避免日志过大，仅记录部分内容
                String logBody = responseBody.length() > 200 ? 
                    responseBody.substring(0, 200) + "..." : responseBody;
                logger.info("[Java] 收到响应JSON: {}", logBody);
                
                // 手动解析JSON
                JsonNode rootNode = objectMapper.readTree(responseBody);
                
                if (rootNode.has("success") && rootNode.get("success").asBoolean()) {
                    // 使用新的格式解析特征
                    if (rootNode.has("featureValues") && rootNode.get("featureValues").isArray()) {
                        JsonNode featureValuesNode = rootNode.get("featureValues");
                        logger.info("[Java] 特征值数组节点类型: {}, 元素数: {}", 
                            featureValuesNode.getNodeType(), featureValuesNode.size());
                        
                        // 直接从JSON节点创建float数组
                        float[] featuresArray = new float[featureValuesNode.size()];
                        
                        for (int i = 0; i < featureValuesNode.size(); i++) {
                            // 使用parseFloat避免任何类型转换问题
                            try {
                                // 获取字符串值并直接解析为float
                                String valueStr = featureValuesNode.get(i).asText();
                                featuresArray[i] = Float.parseFloat(valueStr);
                                
                                // 记录第一个元素的详细信息
                                if (i == 0) {
                                    logger.info("[Java] 特征首元素: 原始值=\"{}\", 转换后={}, 类型=float", 
                                        valueStr, featuresArray[0]);
                                }
                            } catch (NumberFormatException e) {
                                logger.error("无法解析特征值: " + featureValuesNode.get(i).asText(), e);
                                throw new RuntimeException("特征解析失败: " + e.getMessage());
                            }
                        }
                        
                        logger.info("特征提取成功，特征向量长度: {}", featuresArray.length);
                        if (featuresArray.length > 0) {
                            logger.debug("第一个特征值示例: {}", featuresArray[0]);
                        }
                        
                        return featuresArray;
                    } else {
                        logger.error("解析特征失败: 'featureValues'字段不存在或不是数组");
                    }
                } else {
                    // 获取错误信息
                    String errorMsg = rootNode.has("error") ? 
                        rootNode.get("error").asText() : "未知错误";
                    logger.warn("特征提取服务返回错误: {}", errorMsg);
                }
                
                throw new RuntimeException("特征提取失败: " + responseBody);
            } else {
                logger.warn("特征提取服务返回非预期响应: {}, body: {}", 
                    response.getStatusCode(), response.getBody());
                throw new RuntimeException("特征提取服务返回错误响应");
            }
        } catch (Exception e) {
            logger.error("调用特征提取服务时发生错误: " + e.getMessage());
            throw new RuntimeException("特征提取失败: " + e.getMessage(), e);
        }
    }
    
    /**
     * 检查Python服务健康状态
     * @return 服务是否正常运行
     */
    public boolean isServiceHealthy() {
        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(
                extractionServiceUrl + "/health", 
                Map.class
            );
            
            return response.getStatusCode() == HttpStatus.OK && 
                   response.getBody() != null && 
                   "ok".equals(response.getBody().get("status"));
        } catch (Exception e) {
            logger.warn("特征提取服务健康检查失败: " + e.getMessage());
            return false;
        }
    }
    
    // 计算两个特征向量的余弦相似度
    public double calculateCosineSimilarity(float[] features1, float[] features2) {
        if (features1.length != features2.length) {
            throw new IllegalArgumentException("特征向量维度不一致: " + 
                    features1.length + " vs " + features2.length);
        }
        
        double dotProduct = 0.0;
        for (int i = 0; i < features1.length; i++) {
            dotProduct += features1[i] * features2[i];
        }
        
        // 由于特征向量已经通过L2归一化，所以不需要再除以向量模长
        // 如果要保险，可以再次计算模长
        return dotProduct;
    }
}
