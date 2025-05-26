package com.example.museum.mapper;

import com.example.museum.entity.Artifact;
import com.example.museum.entity.Like;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 点赞Mapper接口，处理点赞数据的数据库操作
 */
@Mapper
public interface LikeMapper {

    /**
     * 获取用户的所有点赞记录
     * 
     * @param userId 用户ID
     * @return 点赞列表
     */
    @Select("SELECT l.*, a.name as artifactName, a.image_url as artifactImageUrl " +
           "FROM likes l " +
           "JOIN artifact a ON l.artifact_id = a.artifact_id " +
           "WHERE l.user_id = #{userId}")
    List<Like> getLikesByUserId(Integer userId);

    /**
     * 获取用户点赞的所有文物信息
     * 
     * @param userId 用户ID
     * @return 文物列表
     */
    @Select("SELECT a.* FROM artifact a " +
           "JOIN likes l ON a.artifact_id = l.artifact_id " +
           "WHERE l.user_id = #{userId}")
    List<Artifact> getLikedArtifactsByUserId(Integer userId);

    /**
     * 添加点赞
     * 
     * @param userId     用户ID
     * @param artifactId 文物ID
     * @return 受影响的行数
     */
    @Insert("INSERT INTO likes(user_id, artifact_id) VALUES(#{userId}, #{artifactId})")
    int addLike(@Param("userId") Integer userId, @Param("artifactId") Integer artifactId);

    /**
     * 取消点赞
     * 
     * @param userId     用户ID
     * @param artifactId 文物ID
     * @return 受影响的行数
     */
    @Delete("DELETE FROM likes WHERE user_id = #{userId} AND artifact_id = #{artifactId}")
    int removeLike(@Param("userId") Integer userId, @Param("artifactId") Integer artifactId);

    /**
     * 检查用户是否已点赞某文物
     * 
     * @param userId     用户ID
     * @param artifactId 文物ID
     * @return 点赞记录数量（0表示未点赞，1表示已点赞）
     */
    @Select("SELECT COUNT(*) FROM likes WHERE user_id = #{userId} AND artifact_id = #{artifactId}")
    int checkLikeExists(@Param("userId") Integer userId, @Param("artifactId") Integer artifactId);

    /**
     * 增加文物的点赞数
     * 
     * @param artifactId 文物ID
     * @return 受影响的行数
     */
    @Update("UPDATE artifact SET likes = likes + 1 WHERE artifact_id = #{artifactId}")
    int incrementArtifactLikes(Integer artifactId);

    /**
     * 减少文物的点赞数（确保不小于0）
     * 
     * @param artifactId 文物ID
     * @return 受影响的行数
     */
    @Update("UPDATE artifact SET likes = GREATEST(0, likes - 1) WHERE artifact_id = #{artifactId}")
    int decrementArtifactLikes(Integer artifactId);

    /**
     * 获取文物的点赞数量
     *
     * @param artifactId 文物ID
     * @return 点赞数量
     */
    @Select("SELECT likes FROM artifact WHERE artifact_id = #{artifactId}")
    int getArtifactLikesCount(Integer artifactId);
}