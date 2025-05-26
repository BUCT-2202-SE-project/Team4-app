package com.example.museum.service;

import com.example.museum.dto.ApiResponse;
import com.example.museum.dto.UserLoginRequest;
import com.example.museum.dto.UserRegisterRequest;
import com.example.museum.dto.UserUpdateRequest;
import com.example.museum.entity.User;

/**
 * 用户服务接口
 */
public interface UserService {
    
    /**
     * 用户注册
     * @param request 注册请求对象
     * @return 注册结果响应
     */
    ApiResponse<User> register(UserRegisterRequest request);
    
    /**
     * 用户登录
     * @param request 登录请求对象
     * @return 登录结果响应
     */
    ApiResponse<User> login(UserLoginRequest request);
    
    /**
     * 获取用户信息
     * @param userId 用户ID
     * @return 用户信息响应
     */
    ApiResponse<User> getUserInfo(Integer userId);
    
    /**
     * 更新用户信息
     * @param request 更新请求对象
     * @return 更新结果响应
     */
    ApiResponse<User> updateUser(UserUpdateRequest request);
    
    /**
     * 删除用户
     * @param userId 用户ID
     * @return 删除结果响应
     */
    ApiResponse<Boolean> deleteUser(Integer userId);
}