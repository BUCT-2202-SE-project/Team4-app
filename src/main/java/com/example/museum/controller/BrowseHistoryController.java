package com.example.museum.controller;

import com.example.museum.dto.AddBrowseHistoryRequest;
import com.example.museum.dto.ApiResponse;
import com.example.museum.dto.BrowseHistoryDTO;
import com.example.museum.service.BrowseHistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 浏览历史控制器
 */
@RestController
@RequestMapping("/api")
public class BrowseHistoryController {

    private final BrowseHistoryService browseHistoryService;

    @Autowired
    public BrowseHistoryController(BrowseHistoryService browseHistoryService) {
        this.browseHistoryService = browseHistoryService;
    }

    /**
     * 获取用户的浏览历史记录
     * @param userId 用户ID
     * @return 包含浏览历史的响应
     */
    @GetMapping("/user/browse-history")
    public ApiResponse<List<BrowseHistoryDTO>> getUserBrowseHistory(@RequestParam Integer userId) {
        if (userId == null || userId <= 0) {
            return ApiResponse.error("无效的用户ID");
        }

        try {
            List<BrowseHistoryDTO> histories = browseHistoryService.getUserBrowseHistory(userId);
            return ApiResponse.success(histories);
        } catch (Exception e) {
            return ApiResponse.error("获取浏览历史失败: " + e.getMessage());
        }
    }

    /**
     * 添加浏览记录
     * @param request 添加浏览记录请求
     * @return 操作结果
     */
    @PostMapping("/browse-history/add")
    public ApiResponse<?> addBrowseHistory(@RequestBody AddBrowseHistoryRequest request) {
        return browseHistoryService.addBrowseHistory(request);
    }

    /**
     * 删除单条浏览历史记录
     * @param id 记录ID
     * @param userId 用户ID
     * @return 操作结果
     */
    @DeleteMapping("/browse-history/{id}")
    public ApiResponse<?> deleteHistory(@PathVariable Integer id, @RequestParam Integer userId) {
        if (id == null || userId == null || userId <= 0) {
            return ApiResponse.error("无效的参数");
        }
        
        try {
            return browseHistoryService.deleteHistory(id, userId);
        } catch (Exception e) {
            return ApiResponse.error("删除浏览记录失败: " + e.getMessage());
        }
    }
    
    /**
     * 删除用户的所有浏览历史记录
     * @param userId 用户ID
     * @return 操作结果
     */
    @DeleteMapping("/user/browse-history/all")
    public ApiResponse<?> deleteAllHistory(@RequestParam Integer userId) {
        if (userId == null || userId <= 0) {
            return ApiResponse.error("无效的用户ID");
        }
        
        try {
            return browseHistoryService.deleteAllHistoryByUserId(userId);
        } catch (Exception e) {
            return ApiResponse.error("删除所有浏览记录失败: " + e.getMessage());
        }
    }
}
