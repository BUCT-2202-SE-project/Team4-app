package com.example.museum.entity;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "user_browse_history")
public class UserBrowseHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "artifact_id", nullable = false)
    private Integer artifactId;

    @Column(name = "browse_time")
    private LocalDateTime browseTime = LocalDateTime.now();
}
