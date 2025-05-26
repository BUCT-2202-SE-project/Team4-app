package com.example.museum.config.jackson;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/**
 * 自定义反序列化器，将各种数值类型转换为Double
 */
public class NumberToDoubleDeserializer extends JsonDeserializer<Double> {
    
    private static final Logger logger = LoggerFactory.getLogger(NumberToDoubleDeserializer.class);
    
    @Override
    public Double deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException {
        JsonNode node = jp.getCodec().readTree(jp);
        
        // 记录接收到的原始数据类型和值
        String nodeType = node.getNodeType().toString();
        String fieldName = jp.getCurrentName();
        String text = node.toString();
        logger.debug("反序列化字段 [{}]，节点类型: {}，原始值: {}", fieldName, nodeType, text);
        
        if (node.isNumber()) {
            // 可以处理INTEGER, FLOAT, DOUBLE等数字类型
            Double value = node.asDouble();
            logger.debug("成功将数字类型 {} 转换为Double: {}", nodeType, value);
            return value;
        } else if (node.isTextual()) {
            // 处理字符串形式的数字
            try {
                Double value = Double.parseDouble(node.asText());
                logger.debug("成功将字符串 '{}' 转换为Double: {}", node.asText(), value);
                return value;
            } catch (NumberFormatException e) {
                logger.warn("无法将字符串 '{}' 转换为Double", node.asText());
                throw new IOException("无法将字符串转换为Double: " + e.getMessage());
            }
        } else {
            // 其他类型无法转换
            logger.error("不支持的节点类型: {}，无法转换为Double", nodeType);
            throw new IOException("不支持的类型转换为Double: " + nodeType);
        }
    }
}
