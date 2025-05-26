package com.example.museum.repository;

import com.example.museum.entity.Artifact;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Repository
public interface ArtifactRepository extends JpaRepository<Artifact, Integer> {
    
    /**
     * 根据名称查询文物（模糊查询）
     */
    List<Artifact> findByNameContaining(String name);
    
    /**
     * 根据年代查询文物
     */
    List<Artifact> findByEra(String era);
    
    /**
     * 根据类型查询文物
     */
    List<Artifact> findByType(String type);
    
    /**
     * 根据博物馆查询文物
     */
    List<Artifact> findByMuseum(String museum);
    
    /**
     * 增加文物的点赞数
     */
    @Modifying
    @Transactional
    @Query("UPDATE Artifact a SET a.likes = a.likes + 1 WHERE a.id = :id")
    void incrementLikes(@Param("id") Integer id);
    
    /**
     * 减少文物的点赞数
     */
    @Modifying
    @Transactional
    @Query("UPDATE Artifact a SET a.likes = a.likes - 1 WHERE a.id = :id AND a.likes > 0")
    void decrementLikes(@Param("id") Integer id);
    
    /**
     * 获取文物的点赞数
     */
    @Query("SELECT a.likes FROM Artifact a WHERE a.id = :id")
    Integer getLikes(@Param("id") Integer id);
    
    // 删除以下与拼音相关的查询方法:
    // - findByNamePinyinContaining(String pinyin)
    // - findByNamePinyinStartingWith(String pinyin)
    // - findByNameOrNamePinyinContaining(String keyword, String keyword)
    // - 其他任何拼音查询相关方法
}
