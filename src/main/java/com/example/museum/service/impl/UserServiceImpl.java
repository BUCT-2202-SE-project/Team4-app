package com.example.museum.service.impl;

import com.example.museum.dto.ApiResponse;
import com.example.museum.dto.UserLoginRequest;
import com.example.museum.dto.UserRegisterRequest;
import com.example.museum.dto.UserUpdateRequest;
import com.example.museum.entity.User;
import com.example.museum.mapper.UserMapper;
import com.example.museum.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 用户服务实现类
 */
@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;
    
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public ApiResponse<User> register(UserRegisterRequest request) {
        // 参数校验
        if (!StringUtils.hasText(request.getUsername()) || 
            !StringUtils.hasText(request.getPassword()) || 
            !StringUtils.hasText(request.getEmail())) {
            return ApiResponse.error("用户名、密码和邮箱不能为空");
        }
        
        // 检查用户名是否已存在
        User existingUser = userMapper.findByUsername(request.getUsername());
        if (existingUser != null) {
            return ApiResponse.error("用户名已被使用");
        }
        
        // 检查邮箱是否已存在
        existingUser = userMapper.findByEmail(request.getEmail());
        if (existingUser != null) {
            return ApiResponse.error("邮箱已被注册");
        }
        
        // 创建新用户并加密密码
        User user = new User(
                request.getUsername(),
                passwordEncoder.encode(request.getPassword()),
                request.getEmail()
        );
        
        try {
            // 保存用户到数据库
            userMapper.insert(user);
            
            // 返回注册成功的用户信息(不包含密码)
            user.setPassword(null);
            return ApiResponse.success("注册成功", user);
        } catch (Exception e) {
            return ApiResponse.error("注册失败：" + e.getMessage());
        }
    }

    @Override
    public ApiResponse<User> login(UserLoginRequest request) {
        // 参数校验
        if (request.getUserId() == null || 
            !StringUtils.hasText(request.getPassword())) {
            return ApiResponse.error("用户ID和密码不能为空");
        }
        
        // 查询用户
        User user = userMapper.findById(request.getUserId());
        if (user == null) {
            return ApiResponse.error("用户ID不存在");
        }
        
        // 验证密码 - 修改密码验证逻辑
        // 检查密码是否为BCrypt格式，如果是则使用BCrypt验证，否则直接比较
        if (user.getPassword().startsWith("$2a$") || user.getPassword().startsWith("$2b$") || user.getPassword().startsWith("$2y$")) {
            // 密码是BCrypt格式，使用BCrypt验证
            if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
                return ApiResponse.error("密码错误");
            }
        } else {
            // 密码不是BCrypt格式，直接比较明文密码
            if (!request.getPassword().equals(user.getPassword())) {
                return ApiResponse.error("密码错误");
            }
        }
        
        // 检查用户状态
        if (!"正常".equals(user.getPermissionStatus())) {
            return ApiResponse.error("账号已被限制，请联系管理员");
        }
        
        // 返回登录成功的用户信息(不包含密码)
        user.setPassword(null);
        return ApiResponse.success("登录成功", user);
    }

    @Override
    public ApiResponse<User> getUserInfo(Integer userId) {
        if (userId == null) {
            return ApiResponse.error("用户ID不能为空");
        }
        
        User user = userMapper.findById(userId);
        if (user == null) {
            return ApiResponse.error("用户不存在");
        }
        
        // 不返回密码
        user.setPassword(null);
        return ApiResponse.success(user);
    }
    
    @Override
    public ApiResponse<User> updateUser(UserUpdateRequest request) {
        // 参数校验
        if (request.getUserId() == null) {
            return ApiResponse.error("用户ID不能为空");
        }
        
        if (!StringUtils.hasText(request.getUsername())) {
            return ApiResponse.error("用户名不能为空");
        }
        
        if (!StringUtils.hasText(request.getEmail())) {
            return ApiResponse.error("邮箱不能为空");
        }
        
        // 检查用户是否存在
        User existingUser = userMapper.findById(request.getUserId());
        if (existingUser == null) {
            return ApiResponse.error("用户不存在");
        }
        
        // 检查用户名是否已被其他用户使用
        User userWithSameName = userMapper.findByUsername(request.getUsername());
        if (userWithSameName != null && !userWithSameName.getUserId().equals(request.getUserId())) {
            return ApiResponse.error("用户名已被使用");
        }
        
        // 检查邮箱是否已被其他用户使用
        User userWithSameEmail = userMapper.findByEmail(request.getEmail());
        if (userWithSameEmail != null && !userWithSameEmail.getUserId().equals(request.getUserId())) {
            return ApiResponse.error("邮箱已被注册");
        }
        
        // 更新用户信息
        existingUser.setUsername(request.getUsername());
        existingUser.setEmail(request.getEmail());
        
        try {
            userMapper.update(existingUser);
            
            // 不返回密码
            existingUser.setPassword(null);
            return ApiResponse.success("更新成功", existingUser);
        } catch (Exception e) {
            return ApiResponse.error("更新失败：" + e.getMessage());
        }
    }
    
    @Override
    public ApiResponse<Boolean> deleteUser(Integer userId) {
        if (userId == null) {
            return ApiResponse.error("用户ID不能为空");
        }
        
        // 检查用户是否存在
        User existingUser = userMapper.findById(userId);
        if (existingUser == null) {
            return ApiResponse.error("用户不存在");
        }
        
        try {
            // 执行删除操作
            int result = userMapper.delete(userId);
            
            if (result > 0) {
                return ApiResponse.success("用户删除成功", true);
            } else {
                return ApiResponse.error("用户删除失败");
            }
        } catch (Exception e) {
            return ApiResponse.error("删除用户时发生错误：" + e.getMessage());
        }
    }
}