package com.example.museum.controller;

import com.example.museum.dto.ApiResponse;
import com.example.museum.dto.UserLoginRequest;
import com.example.museum.dto.UserRegisterRequest;
import com.example.museum.dto.UserUpdateRequest;
import com.example.museum.entity.User;
import com.example.museum.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 用户控制器
 * 负责处理用户登录、注册等请求
 */
@RestController
@RequestMapping("/api/user")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    /**
     * 用户注册接口
     * @param request 注册请求
     * @return 注册结果
     */
    @PostMapping("/register")
    public ApiResponse<User> register(@RequestBody UserRegisterRequest request) {
        return userService.register(request);
    }
    
    /**
     * 用户登录接口
     * @param request 登录请求
     * @return 登录结果
     */
    @PostMapping("/login")
    public ApiResponse<User> login(@RequestBody UserLoginRequest request) {
        return userService.login(request);
    }
    
    /**
     * 获取用户信息接口
     * @param userId 用户ID
     * @return 用户信息
     */
    @GetMapping("/info/{userId}")
    public ApiResponse<User> getUserInfo(@PathVariable Integer userId) {
        return userService.getUserInfo(userId);
    }
    
    /**
     * 更新用户信息接口
     * @param request 更新请求
     * @return 更新结果
     */
    @PutMapping("/update")
    public ApiResponse<User> updateUser(@RequestBody UserUpdateRequest request) {
        return userService.updateUser(request);
    }
    
    /**
     * 删除用户接口
     * @param userId 用户ID
     * @return 删除结果
     */
    @DeleteMapping("/delete/{userId}")
    public ApiResponse<Boolean> deleteUser(@PathVariable Integer userId) {
        return userService.deleteUser(userId);
    }
}