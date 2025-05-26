package com.example.museum.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 本地文件存储服务实现
 */
@Service
public class LocalStorageService implements StorageService {

    @Value("${storage.location:uploads}")
    private String storageLocation;
    
    @Value("${server.port}")
    private String serverPort;
    
    @Override
    public String store(byte[] content, String filename) {
        try {
            Path uploadPath = Paths.get(storageLocation);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            Path filePath = uploadPath.resolve(filename);
            Files.write(filePath, content);
            
            return getUrl(filename);
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file", e);
        }
    }

    @Override
    public String getUrl(String filename) {
        return "http://localhost:" + serverPort + "/" + storageLocation + "/" + filename;
    }

    @Override
    public void delete(String filename) {
        try {
            Path filePath = Paths.get(storageLocation).resolve(filename);
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            throw new RuntimeException("Failed to delete file", e);
        }
    }
}
