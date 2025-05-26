package com.example.museum.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class BrowseHistoryDTO {
    private Integer id;
    private Integer userId;
    private Integer artifactId;
    private String artifactName;
    private String artifactImage;
    private LocalDateTime browseTime;
}
