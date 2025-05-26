package com.example.museum.dto;

import lombok.Data;

/**
 * API响应数据传输对象
 * @param <T> 响应数据类型
 */
@Data
public class ApiResponse<T> {
    private boolean success;    // 请求是否成功
    private String message;     // 响应消息
    private T data;             // 响应数据

    // 私有构造函数
    private ApiResponse(boolean success, String message, T data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }

    // 成功响应，带数据
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, "Success", data);
    }

    // 成功响应，带数据和消息
    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(true, message, data);
    }

    // 错误响应，仅消息
    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, message, null);
    }

    // 错误响应，带错误码和消息
    public static <T> ApiResponse<T> error(String message, T data) {
        return new ApiResponse<>(false, message, data);
    }
}