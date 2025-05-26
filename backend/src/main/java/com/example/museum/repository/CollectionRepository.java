package com.example.museum.repository;

import com.example.museum.entity.Artifact;
import com.example.museum.entity.ArtifactCollection; // 修改引入的实体类
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CollectionRepository extends JpaRepository<ArtifactCollection, Integer> { // 修改实体类类型
    
    /**
     * 查找用户收藏的所有文物
     * @param userId 用户ID
     * @return 文物列表
     */
    @Query("SELECT a FROM Artifact a JOIN ArtifactCollection c ON a.id = c.artifactId WHERE c.userId = :userId") // 修改查询中的实体类名
    List<Artifact> findArtifactsByUserId(@Param("userId") Integer userId);
    
    /**
     * 根据用户ID和文物ID查找收藏记录
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 收藏记录
     */
    Optional<ArtifactCollection> findByUserIdAndArtifactId(Integer userId, Integer artifactId); // 修改返回类型
    
    /**
     * 检查用户是否已收藏某文物
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 是否存在收藏记录
     */
    boolean existsByUserIdAndArtifactId(Integer userId, Integer artifactId);
}
