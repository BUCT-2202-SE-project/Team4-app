package com.example.museum.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

/**
 * 服务配置类，用于管理Python特征提取服务的生命周期
 */
@Configuration
public class ServiceConfig {
    
    private static final Logger logger = Logger.getLogger(ServiceConfig.class.getName());
    
    @Value("${feature.extraction.service.autostart:true}")
    private boolean autoStartPythonService;
    
    @Value("${feature.extraction.service.path:}")
    private String pythonServicePath;
    
    private Process pythonServiceProcess;
    
    /**
     * 应用启动时检查并可能启动Python服务
     */
    @PostConstruct
    public void startPythonService() {
        if (autoStartPythonService) {
            try {
                logger.info("正在启动Python特征提取服务...");
                
                // 如果未指定路径，使用默认路径
                String servicePath = pythonServicePath.isEmpty() ? 
                    "D:/collegelife/Grade_three_second/SWE/backend/museum/src/main/python" : 
                    pythonServicePath;
                
                File serviceDir = new File(servicePath);
                
                // 使用批处理脚本启动服务
                ProcessBuilder pb = new ProcessBuilder("cmd.exe", "/c", "start_service.bat");
                pb.directory(serviceDir);
                pb.redirectErrorStream(true);
                
                pythonServiceProcess = pb.start();
                
                // 读取输出（可选）
                new Thread(() -> {
                    try (BufferedReader reader = new BufferedReader(
                            new InputStreamReader(pythonServiceProcess.getInputStream()))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            logger.info("Python服务: " + line);
                        }
                    } catch (Exception e) {
                        logger.warning("读取Python服务输出时出错: " + e.getMessage());
                    }
                }).start();
                
                // 等待服务启动
                TimeUnit.SECONDS.sleep(5);
                logger.info("Python特征提取服务启动成功");
            } catch (Exception e) {
                logger.severe("启动Python特征提取服务失败: " + e.getMessage());
            }
        }
    }
    
    /**
     * 应用关闭时停止Python服务
     */
    @PreDestroy
    public void stopPythonService() {
        if (pythonServiceProcess != null && pythonServiceProcess.isAlive()) {
            logger.info("正在停止Python特征提取服务...");
            pythonServiceProcess.destroy();
            try {
                if (!pythonServiceProcess.waitFor(10, TimeUnit.SECONDS)) {
                    pythonServiceProcess.destroyForcibly();
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            logger.info("Python特征提取服务已停止");
        }
    }
    
    @Bean
    public boolean pythonServiceEnabled() {
        return autoStartPythonService;
    }
}
