package com.example.museum.mapper;

import com.example.museum.entity.User;
import org.apache.ibatis.annotations.*;

/**
 * 用户数据访问接口
 */
@Mapper
public interface UserMapper {
    
    /**
     * 通过用户名查询用户
     */
    @Select("SELECT * FROM user WHERE username = #{username}")
    User findByUsername(String username);
    
    /**
     * 通过邮箱查询用户
     */
    @Select("SELECT * FROM user WHERE email = #{email}")
    User findByEmail(String email);
    
    /**
     * 通过ID查询用户
     */
    @Select("SELECT * FROM user WHERE user_id = #{userId}")
    User findById(Integer userId);
    
    /**
     * 插入新用户并返回生成的ID
     */
    @Insert("INSERT INTO user(username, password, email, register_time, permission_status) " +
            "VALUES(#{username}, #{password}, #{email}, #{registerTime}, #{permissionStatus})")
    @Options(useGeneratedKeys = true, keyProperty = "userId", keyColumn = "user_id")
    int insert(User user);
    
    /**
     * 更新用户信息
     */
    @Update("UPDATE user SET username = #{username}, email = #{email}, " +
            "permission_status = #{permissionStatus} WHERE user_id = #{userId}")
    int update(User user);
    
    /**
     * 更新用户密码
     */
    @Update("UPDATE user SET password = #{password} WHERE user_id = #{userId}")
    int updatePassword(Integer userId, String password);
    
    /**
     * 删除用户
     */
    @Delete("DELETE FROM user WHERE user_id = #{userId}")
    int delete(Integer userId);
}