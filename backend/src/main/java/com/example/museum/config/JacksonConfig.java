package com.example.museum.config;

import com.example.museum.config.jackson.NumberToDoubleDeserializer;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import java.text.SimpleDateFormat;

/**
 * Jackson配置类，增强类型转换能力，特别是对Java 8日期时间类型的支持
 */
@Configuration
public class JacksonConfig {

    private static final Logger logger = LoggerFactory.getLogger(JacksonConfig.class);
    
    @Bean
    @Primary
    public ObjectMapper objectMapper() {
        logger.info("配置增强型ObjectMapper，支持数值类型自动转换和Java 8日期时间类型");
        
        ObjectMapper objectMapper = new ObjectMapper();
        
        // 启用宽松的类型转换
        objectMapper.configure(DeserializationFeature.ACCEPT_FLOAT_AS_INT, true);
        objectMapper.configure(DeserializationFeature.ACCEPT_SINGLE_VALUE_AS_ARRAY, true);
        objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        
        // 注册自定义数值处理模块
        SimpleModule numberModule = new SimpleModule("NumberConversionModule");
        numberModule.addDeserializer(Double.class, new NumberToDoubleDeserializer());
        objectMapper.registerModule(numberModule);
        
        // 添加Java 8日期时间模块支持
        objectMapper.registerModule(new JavaTimeModule());
        
        // 配置日期时间输出格式
        objectMapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
        objectMapper.setDateFormat(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"));
        
        logger.info("ObjectMapper配置完成，已启用数值类型自动转换和Java 8日期时间支持");
        return objectMapper;
    }
}
