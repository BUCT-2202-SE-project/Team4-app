package com.example.museum.dto;

/**
 * 用户登录请求DTO
 */
public class UserLoginRequest {
    private Integer userId;
    private String password;
    
    public Integer getUserId() {
        return userId;
    }
    
    public void setUserId(Integer userId) {
        this.userId = userId;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
}