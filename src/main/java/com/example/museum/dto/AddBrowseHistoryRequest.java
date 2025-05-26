package com.example.museum.dto;

import lombok.Data;

@Data
public class AddBrowseHistoryRequest {
    private Integer userId;
    private Integer artifactId;
}
