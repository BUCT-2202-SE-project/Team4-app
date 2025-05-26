package com.example.museum.dto;

/**
 * 用户信息更新请求DTO
 */
public class UserUpdateRequest {
    private Integer userId;
    private String username;
    private String email;

    public UserUpdateRequest() {
    }

    public UserUpdateRequest(Integer userId, String username, String email) {
        this.userId = userId;
        this.username = username;
        this.email = email;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    @Override
    public String toString() {
        return "UserUpdateRequest{" +
                "userId=" + userId +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
}
