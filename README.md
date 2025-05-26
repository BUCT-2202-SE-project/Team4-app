# 国家博物馆导览系统

这是一个基于HarmonyOS和Spring Boot的博物馆导览应用系统，提供文物浏览、收藏、点赞、评论、图像搜索等功能，为用户提供丰富的博物馆参观体验。

## 项目结构

项目分为前端和后端两部分：

```
SWE/
├── frontend/           # HarmonyOS前端应用
└── backend/            
    └── museum/         # Spring Boot后端服务
```

## 前端项目 (frontend)

### 技术栈
- HarmonyOS应用开发框架
- ArkTS/TS语言

### 主要页面
- **首页** - 展示热门文物和博物馆资讯
- **文物列表** - 展示所有文物，支持搜索和筛选
- **文物详情** - 展示文物详细信息，支持点赞、评论和收藏
- **全景国博** - 博物馆虚拟导览功能
- **以图搜图** - 通过上传图片搜索相似文物
- **个人中心** - 管理个人收藏、点赞和评论

### 安装与运行
1. 安装DevEco Studio
2. 导入前端项目
3. 配置设备（真机或模拟器）
4. 运行应用

## 后端项目 (backend/museum)

### 技术栈
- Spring Boot 2.x
- Spring Data JPA
- MySQL数据库
- RESTful API架构

### 主要功能
- 文物信息管理
- 用户收藏管理
- 点赞和评论系统
- 图像特征提取和相似度匹配
- 用户认证和授权

### 核心API
- `/api/artifacts` - 文物相关接口
- `/api/collections` - 收藏相关接口
- `/api/likes` - 点赞相关接口
- `/api/comments` - 评论相关接口
- `/api/image-search` - 图像搜索接口

### 安装与运行
1. 确保已安装JDK 11+和Maven
2. 配置MySQL数据库
3. 修改`application.properties`中的数据库连接信息
4. 运行以下命令:
   ```
   cd backend/museum
   mvn spring-boot:run
   ```

## 数据库设计

系统使用MySQL数据库，主要包含以下表：
- `artifact` - 存储文物信息
- `user` - 用户信息
- `collection` - 用户收藏
- `like` - 用户点赞
- `comment` - 用户评论
- `browse_history` - 浏览历史

## 开发团队

- 开发者：[李典坤，彭秀涛，张琪伟，段志豪，赵一泽]
- 所属课程：软件工程

