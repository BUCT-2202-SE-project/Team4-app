package com.example.museum.storage;

import org.springframework.stereotype.Service;

/**
 * 存储服务抽象接口
 * 为未来迁移到阿里云OSS等存储服务预留扩展点
 */
@Service
public interface StorageService {
    
    /**
     * 存储文件并返回访问URL
     */
    String store(byte[] content, String filename);
    
    /**
     * 获取文件访问URL
     */
    String getUrl(String filename);
    
    /**
     * 删除文件
     */
    void delete(String filename);
}
