package com.example.museum.mapper;

import com.example.museum.entity.ArtifactCollection;
import com.example.museum.entity.Artifact;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 收藏功能的Mapper接口
 */
@Mapper
public interface CollectionMapper {
    
    /**
     * 添加收藏记录
     * @param collection 收藏记录
     * @return 影响的行数
     */
    @Insert("INSERT INTO collection(user_id, artifact_id, collect_time) VALUES(#{userId}, #{artifactId}, #{createTime})")
    @Options(useGeneratedKeys = true, keyProperty = "id", keyColumn = "collection_id")
    int insert(ArtifactCollection collection);
    
    /**
     * 删除收藏记录
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 影响的行数
     */
    @Delete("DELETE FROM collection WHERE user_id = #{userId} AND artifact_id = #{artifactId}")
    int delete(@Param("userId") Integer userId, @Param("artifactId") Integer artifactId);
    
    /**
     * 查询用户是否已收藏指定文物
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 收藏记录数量，大于0表示已收藏
     */
    @Select("SELECT COUNT(*) FROM collection WHERE user_id = #{userId} AND artifact_id = #{artifactId}")
    int checkCollection(@Param("userId") Integer userId, @Param("artifactId") Integer artifactId);
    
    /**
     * 获取用户收藏的所有文物ID列表
     * @param userId 用户ID
     * @return 文物ID列表
     */
    @Select("SELECT artifact_id FROM collection WHERE user_id = #{userId}")
    List<Integer> getCollectedArtifactIds(Integer userId);
    
    /**
     * 获取用户收藏的文物信息（包含文物详情）
     * @param userId 用户ID
     * @return 文物列表
     */
    @Select("SELECT a.* FROM artifact a JOIN collection c ON a.artifact_id = c.artifact_id WHERE c.user_id = #{userId} ORDER BY c.collect_time DESC")
    List<Artifact> getCollectedArtifacts(Integer userId);
}