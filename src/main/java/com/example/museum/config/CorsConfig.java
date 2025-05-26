package com.example.museum.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        
        // 添加允许的前端源，包括模拟器和设备上的应用
        config.setAllowedOriginPatterns(Arrays.asList("*"));
        
        // 允许凭证
        config.setAllowCredentials(true);
        
        // 允许的请求头和方法
        config.addAllowedHeader("*");
        config.addAllowedMethod("*");
        
        // 允许的暴露头信息
        config.addExposedHeader("*");
        
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
