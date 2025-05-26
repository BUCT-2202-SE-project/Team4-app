package com.example.museum.config.jackson;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * 自定义反序列化器，处理Double数组/列表
 */
public class NumberToDoubleListDeserializer extends JsonDeserializer<List<Double>> {
    
    private static final Logger logger = LoggerFactory.getLogger(NumberToDoubleListDeserializer.class);
    
    @Override
    public List<Double> deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException {
        if (jp.isExpectedStartArrayToken()) {
            List<Double> result = new ArrayList<>();
            int count = 0;
            
            logger.debug("开始反序列化数组，字段名: {}", jp.getCurrentName());
            
            while (jp.nextToken() != JsonToken.END_ARRAY) {
                // 对每个元素使用NumberToDoubleDeserializer的逻辑
                if (jp.getCurrentToken().isNumeric()) {
                    double value = jp.getDoubleValue();
                    result.add(value);
                    
                    // 记录部分样本，避免日志过大
                    if (count < 5 || count % 1000 == 0) {
                        logger.debug("数组元素 #{}: 值={}, 类型={}", 
                            count, value, jp.getCurrentToken());
                    }
                } else if (jp.getCurrentToken() == JsonToken.VALUE_STRING) {
                    try {
                        String text = jp.getText();
                        double value = Double.parseDouble(text);
                        result.add(value);
                        
                        if (count < 5 || count % 1000 == 0) {
                            logger.debug("数组字符串元素 #{}: 原始='{}', 转换值={}", 
                                count, text, value);
                        }
                    } catch (NumberFormatException e) {
                        logger.warn("无法将字符串转换为Double: {}", jp.getText());
                        throw new IOException("无法将字符串转换为Double: " + e.getMessage());
                    }
                } else if (jp.getCurrentToken() == JsonToken.VALUE_NULL) {
                    // 处理null值
                    logger.warn("数组中存在null元素，位置: {}", count);
                    result.add(null);
                } else {
                    logger.error("不支持的数组元素类型: {}", jp.getCurrentToken());
                    throw new IOException("不支持的数组元素类型: " + jp.getCurrentToken());
                }
                count++;
            }
            
            logger.info("成功反序列化Double数组，共{}个元素", result.size());
            return result;
        }
        
        logger.error("预期数组开始标记，但得到: {}", jp.getCurrentToken());
        throw new IOException("无法解析为Double列表：预期数组开始标记，但得到: " + jp.getCurrentToken());
    }
}
