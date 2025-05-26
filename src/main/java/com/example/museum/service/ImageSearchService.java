package com.example.museum.service;

import com.example.museum.entity.Artifact;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.logging.Logger;

/**
 * 图像搜索服务
 */
@Service
public class ImageSearchService {
    
    private static final Logger logger = Logger.getLogger(ImageSearchService.class.getName());
    
    @Autowired
    private ArtifactService artifactService;
    
    @Autowired
    private FeatureExtractionService featureExtractionService;
    
    @Value("${museum.temp.path:temp}")
    private String tempPath;
    
    /**
     * 检查特征提取服务是否健康
     */
    public boolean isFeatureServiceHealthy() {
        return featureExtractionService.isServiceHealthy();
    }
    
    /**
     * 上传图片并查找相似文物
     * @param image 上传的图片文件
     * @param threshold 相似度阈值
     * @param maxResults 最大结果数
     * @return 相似文物列表
     * @throws IOException 如果文件处理出错
     */
    public List<Artifact> searchSimilarArtifacts(MultipartFile image, double threshold, int maxResults) throws IOException {
        // 确保临时目录存在
        File tempDir = new File(tempPath);
        if (!tempDir.exists()) {
            tempDir.mkdirs();
        }
        
        // 保存上传的图片到临时文件
        String originalFilename = image.getOriginalFilename();
        String fileExtension = originalFilename != null && originalFilename.contains(".") ?
                originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
        String filename = UUID.randomUUID().toString() + fileExtension;
        Path filePath = Paths.get(tempPath, filename);
        
        try {
            Files.copy(image.getInputStream(), filePath);
            logger.info("图片已保存到临时路径: " + filePath);
            
            // 提取特征
            float[] features = featureExtractionService.extractFeatures(filePath.toString());
            logger.info("已成功提取特征，长度: " + features.length);
            
            // 将特征数组转换为JSON字符串
            String featureJson = Arrays.toString(features);
            
            // 查找相似文物
            return artifactService.findSimilarArtifacts(featureJson, threshold, maxResults);
        } finally {
            // 确保临时文件被删除
            try {
                Files.deleteIfExists(filePath);
                logger.info("临时文件已删除: " + filePath);
            } catch (IOException e) {
                logger.warning("删除临时文件失败: " + e.getMessage());
            }
        }
    }
    
    /**
     * 使用图像字节数组搜索相似文物（简化版本，使用默认阈值）
     * @param imageData 图像字节数组
     * @param maxResults 最大结果数
     * @return 相似文物列表
     * @throws IOException 如果文件处理出错
     */
    public List<Artifact> searchSimilarArtifacts(byte[] imageData, int maxResults) throws IOException {
        // 确保临时目录存在
        File tempDir = new File(tempPath);
        if (!tempDir.exists()) {
            tempDir.mkdirs();
        }
        
        // 使用默认阈值0.6
        double threshold = 0.6;
        
        // 检查图像格式并选择合适的扩展名
        String fileExtension = ".jpg"; // 默认
        
        // 检查图像头部标记以确定格式
        if (imageData.length >= 4) {
            // PNG格式 (89 50 4E 47)
            if ((imageData[0] & 0xFF) == 0x89 && 
                (imageData[1] & 0xFF) == 0x50 && 
                (imageData[2] & 0xFF) == 0x4E && 
                (imageData[3] & 0xFF) == 0x47) {
                fileExtension = ".png";
                logger.info("检测到PNG格式图像");
            }
            // JPEG格式 (FF D8)
            else if ((imageData[0] & 0xFF) == 0xFF && 
                    (imageData[1] & 0xFF) == 0xD8) {
                fileExtension = ".jpg";
                logger.info("检测到JPEG格式图像");
            } else {
                logger.warning("未知图像格式，将使用默认扩展名");
            }
        }
        
        // 创建临时文件
        String filename = UUID.randomUUID().toString() + fileExtension;
        Path filePath = Paths.get(tempPath, filename);
        
        try {
            // 记录图像数据的前几个字节，用于调试
            StringBuilder hexHeader = new StringBuilder("图像数据头部(十六进制): ");
            for (int i = 0; i < Math.min(16, imageData.length); i++) {
                hexHeader.append(String.format("%02X ", imageData[i] & 0xFF));
            }
            logger.info(hexHeader.toString());

            // 将字节数组写入临时文件
            Files.write(filePath, imageData);
            logger.info("图片字节数据已保存到临时文件: " + filePath);
            
            // 检查文件是否被正确写入
            File savedFile = filePath.toFile();
            if (!savedFile.exists() || savedFile.length() == 0) {
                throw new IOException("图像文件没有被正确保存或为空");
            }
            
            logger.info("已保存临时文件，大小: " + savedFile.length() + " 字节");
            
            try {
                // 提取特征
                float[] features = featureExtractionService.extractFeatures(filePath.toString());
                logger.info("已成功提取特征，长度: " + features.length);
                
                // 将特征数组转换为JSON字符串
                String featureJson = Arrays.toString(features);
                
                // 查找相似文物
                return artifactService.findSimilarArtifacts(featureJson, threshold, maxResults);
            } catch (Exception e) {
                logger.severe("特征提取失败: " + e.getMessage());
                throw e;
            }
        } finally {
            // 确保临时文件被删除
            try {
                Files.deleteIfExists(filePath);
                logger.info("临时文件已删除: " + filePath);
            } catch (IOException e) {
                logger.warning("删除临时文件失败: " + e.getMessage());
            }
        }
    }
    
    /**
     * 通过指定图片路径查找相似文物
     * @param imagePath 图片路径
     * @param threshold 相似度阈值
     * @param maxResults 最大结果数
     * @return 相似文物列表
     */
    public List<Artifact> searchSimilarArtifactsByPath(String imagePath, double threshold, int maxResults) {
        // 提取特征
        float[] features = featureExtractionService.extractFeatures(imagePath);
        logger.info("已成功提取特征，长度: " + features.length);
        
        // 将特征数组转换为JSON字符串
        String featureJson = Arrays.toString(features);
        
        // 查找相似文物
        return artifactService.findSimilarArtifacts(featureJson, threshold, maxResults);
    }
}
