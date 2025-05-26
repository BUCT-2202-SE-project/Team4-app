package com.example.museum.mapper;

import com.example.museum.entity.Comment;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Map;

/**
 * 评论数据访问层接口
 */
@Mapper
public interface CommentMapper {

    /**
     * 根据文物ID查询评论列表，并带上用户名
     * @param artifactId 文物ID
     * @return 评论列表
     */
    @Select("SELECT c.*, u.username FROM comment c " +
           "LEFT JOIN user u ON c.user_id = u.user_id " +
           "WHERE c.artifact_id = #{artifactId} AND c.review_status = '通过' " +
           "ORDER BY c.publish_time DESC")
    List<Comment> findByArtifactId(Integer artifactId);

    /**
     * 查询所有评论
     * @return 所有评论
     */
    @Select("SELECT c.*, u.username FROM comment c " +
           "LEFT JOIN user u ON c.user_id = u.user_id " +
           "ORDER BY c.publish_time DESC")
    List<Comment> findAll();

    /**
     * 添加评论
     * @param comment 评论实体
     * @return 受影响行数
     */
    @Insert("INSERT INTO comment (content, publish_time, user_id, artifact_id, review_status) " +
           "VALUES (#{content}, #{publishTime}, #{userId}, #{artifactId}, #{reviewStatus})")
    @Options(useGeneratedKeys = true, keyProperty = "commentId")
    int insert(Comment comment);

    /**
     * 更新评论审核状态
     * @param commentId 评论ID
     * @param reviewStatus 审核状态
     * @return 受影响行数
     */
    @Update("UPDATE comment SET review_status = #{reviewStatus} WHERE comment_id = #{commentId}")
    int updateReviewStatus(@Param("commentId") Integer commentId, @Param("reviewStatus") String reviewStatus);

    /**
     * 删除评论
     * @param commentId 评论ID
     * @return 受影响行数
     */
    @Delete("DELETE FROM comment WHERE comment_id = #{commentId}")
    int deleteById(Integer commentId);
    
    /**
     * 查询已审核通过的评论和指定用户的未审核评论
     * @param artifactId 文物ID
     * @param userId 用户ID
     * @return 评论列表
     */
    @Select("SELECT c.*, u.username FROM comment c " +
           "LEFT JOIN user u ON c.user_id = u.user_id " +
           "WHERE c.artifact_id = #{artifactId} AND (c.review_status = '通过' OR (c.user_id = #{userId} AND c.review_status = '未通过')) " +
           "ORDER BY c.publish_time DESC")
    List<Comment> findApprovedAndUserPending(@Param("artifactId") Integer artifactId, @Param("userId") Integer userId);

    /**
     * 根据ID查询评论，包括用户名
     * @param commentId 评论ID
     * @return 评论对象
     */
    @Select("SELECT c.*, u.username FROM comment c " +
           "LEFT JOIN user u ON c.user_id = u.user_id " +
           "WHERE c.comment_id = #{commentId}")
    Comment findById(Integer commentId);
    
    /**
     * 更新评论内容
     * @param commentId 评论ID
     * @param content 评论内容
     * @return 受影响行数
     */
    @Update("UPDATE comment SET content = #{content}, review_status = '未通过' WHERE comment_id = #{commentId}")
    int updateContent(@Param("commentId") Integer commentId, @Param("content") String content);

    /**
     * 查询指定用户的所有评论，包括相关的文物信息
     * @param userId 用户ID
     * @return 包含评论和文物信息的列表
     */
    @Select("SELECT c.comment_id AS commentId, c.content, c.publish_time AS publishTime, " +
           "c.review_status AS reviewStatus, c.artifact_id AS artifactId, c.user_id AS userId, " +
           "a.name AS artifactName, a.image_url AS artifactImage " +
           "FROM comment c " +
           "LEFT JOIN artifact a ON c.artifact_id = a.artifact_id " +
           "WHERE c.user_id = #{userId} " +
           "ORDER BY c.publish_time DESC")
    List<Map<String, Object>> findUserCommentsWithArtifactInfo(Integer userId);
}