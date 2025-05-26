package com.example.museum.mapper;

import com.example.museum.entity.Artifact;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ArtifactMapper {
    
    @Select("SELECT * FROM artifact")
    List<Artifact> findAll();
    
    @Select("SELECT * FROM artifact WHERE artifact_id = #{id}")
    Artifact findById(Integer id);
    
    @Select("SELECT * FROM artifact WHERE type = #{type}")
    List<Artifact> findByType(String type);
    
    // 查询所有有特征向量的文物
    @Select("SELECT * FROM artifact WHERE feature IS NOT NULL AND feature != ''")
    List<Artifact> findAllWithFeatures();
}
