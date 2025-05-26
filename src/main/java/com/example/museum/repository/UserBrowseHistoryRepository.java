package com.example.museum.repository;

import com.example.museum.entity.UserBrowseHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface UserBrowseHistoryRepository extends JpaRepository<UserBrowseHistory, Integer> {
    
    /**
     * 查询用户的浏览历史记录
     * @param userId 用户ID
     * @return 用户的浏览历史列表，按浏览时间降序排列
     */
    @Query("SELECT ubh FROM UserBrowseHistory ubh WHERE ubh.userId = :userId ORDER BY ubh.browseTime DESC")
    List<UserBrowseHistory> findByUserIdOrderByBrowseTimeDesc(Integer userId);
    
    /**
     * 通过用户ID和文物ID查找浏览记录
     * @param userId 用户ID
     * @param artifactId 文物ID
     * @return 符合条件的浏览记录
     */
    UserBrowseHistory findByUserIdAndArtifactId(Integer userId, Integer artifactId);    /**
     * 删除指定用户的所有浏览记录
     * @param userId 用户ID
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM UserBrowseHistory h WHERE h.userId = :userId")
    void deleteByUserId(Integer userId);
}
