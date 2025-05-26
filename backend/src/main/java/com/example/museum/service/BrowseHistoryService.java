package com.example.museum.service;

import com.example.museum.dto.ApiResponse;
import com.example.museum.dto.BrowseHistoryDTO;
import com.example.museum.dto.AddBrowseHistoryRequest;
import com.example.museum.entity.Artifact;
import com.example.museum.entity.UserBrowseHistory;
import com.example.museum.repository.UserBrowseHistoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * 浏览历史服务类
 */
@Service
public class BrowseHistoryService {
    
    private final UserBrowseHistoryRepository browseHistoryRepository;
    private final ArtifactService artifactService;
    
    @Autowired
    public BrowseHistoryService(UserBrowseHistoryRepository browseHistoryRepository, 
                               ArtifactService artifactService) {
        this.browseHistoryRepository = browseHistoryRepository;
        this.artifactService = artifactService;
    }
    
    /**
     * 添加浏览记录
     * @param request 添加浏览记录请求
     * @return API响应
     */
    public ApiResponse addBrowseHistory(AddBrowseHistoryRequest request) {
        if (request.getUserId() == null || request.getArtifactId() == null) {
            return ApiResponse.error("用户ID和文物ID不能为空");
        }
        
        try {
            // 检查文物是否存在
            Artifact artifact = artifactService.getArtifactById(request.getArtifactId());
            if (artifact == null) {
                return ApiResponse.error("文物不存在");
            }
            
            // 检查是否已有相同的浏览记录
            UserBrowseHistory existingRecord = browseHistoryRepository
                .findByUserIdAndArtifactId(request.getUserId(), request.getArtifactId());
            
            if (existingRecord != null) {
                // 更新浏览时间
                existingRecord.setBrowseTime(LocalDateTime.now());
                browseHistoryRepository.save(existingRecord);
            } else {
                // 创建新浏览记录
                UserBrowseHistory history = new UserBrowseHistory();
                history.setUserId(request.getUserId());
                history.setArtifactId(request.getArtifactId());
                history.setBrowseTime(LocalDateTime.now());
                
                browseHistoryRepository.save(history);
            }
            
            return ApiResponse.success(true);
        } catch (Exception e) {
            return ApiResponse.error("添加浏览记录失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户的浏览历史记录
     * @param userId 用户ID
     * @return 浏览历史记录DTO列表
     */
    public List<BrowseHistoryDTO> getUserBrowseHistory(Integer userId) {
        List<UserBrowseHistory> histories = browseHistoryRepository.findByUserIdOrderByBrowseTimeDesc(userId);
        List<BrowseHistoryDTO> result = new ArrayList<>();
        
        for (UserBrowseHistory history : histories) {
            BrowseHistoryDTO dto = new BrowseHistoryDTO();
            dto.setId(history.getId());
            dto.setUserId(history.getUserId());
            dto.setArtifactId(history.getArtifactId());
            dto.setBrowseTime(history.getBrowseTime());
            
            // 获取文物信息
            Artifact artifact = artifactService.getArtifactById(history.getArtifactId());
            if (artifact != null) {
                dto.setArtifactName(artifact.getName());
                dto.setArtifactImage(artifact.getImageUrl());
            }
            
            result.add(dto);
        }
        
        return result;
    }
      /**
     * 删除单条浏览记录
     * @param id 浏览记录ID
     * @param userId 用户ID（用于验证权限）
     * @return API响应
     */
    @Transactional
    public ApiResponse deleteHistory(Integer id, Integer userId) {
        if (id == null || userId == null) {
            return ApiResponse.error("记录ID和用户ID不能为空");
        }
        
        try {
            // 查找记录
            Optional<UserBrowseHistory> historyOpt = browseHistoryRepository.findById(id);
            
            if (historyOpt.isEmpty()) {
                return ApiResponse.error("浏览记录不存在");
            }
            
            // 验证该记录是否属于当前用户
            UserBrowseHistory history = historyOpt.get();
            if (!history.getUserId().equals(userId)) {
                return ApiResponse.error("无权删除此记录");
            }
            
            // 删除记录
            browseHistoryRepository.deleteById(id);
            return ApiResponse.success("删除成功");
            
        } catch (Exception e) {
            return ApiResponse.error("删除失败: " + e.getMessage());
        }
    }
      /**
     * 删除用户的所有浏览记录
     * @param userId 用户ID
     * @return API响应
     */
    @Transactional
    public ApiResponse deleteAllHistoryByUserId(Integer userId) {
        if (userId == null) {
            return ApiResponse.error("用户ID不能为空");
        }
        
        try {
            // 查找该用户的所有记录
            List<UserBrowseHistory> histories = browseHistoryRepository.findByUserIdOrderByBrowseTimeDesc(userId);
            
            if (histories.isEmpty()) {
                return ApiResponse.success("没有浏览记录需要删除");
            }
            
            // 删除该用户的所有浏览记录
            browseHistoryRepository.deleteByUserId(userId);
            return ApiResponse.success("已删除所有浏览记录");
            
        } catch (Exception e) {
            return ApiResponse.error("删除失败: " + e.getMessage());
        }
    }
}
