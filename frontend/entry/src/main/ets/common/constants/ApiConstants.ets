
/**
 * API常量类，用于定义后端接口路径
 */
export default class ApiConstants {
  // API 基本路径 - 修改为电脑的实际IP地址
  static readonly SERVER_BASE_URL: string = 'http://localhost:8080'; // 替换为实际的服务器地址
  // 用户相关接口
  static readonly API_LOGIN: string = '/api/user/login';
  static readonly API_REGISTER: string = '/api/user/register';
  static readonly API_USER_INFO: string = '/api/user/info';
  static readonly API_USER_UPDATE: string = '/api/user/update';
  static readonly API_USER_DELETE: string = '/api/user/delete';
  // 文物相关接口
  static readonly API_ARTIFACTS: string = '/api/artifacts';
  static readonly API_ARTIFACT_DETAIL: string = '/api/artifacts/'; // 修正为复数形式的路径
  static readonly API_ARTIFACT_SEARCH: string = '/api/artifacts/search';
  static readonly API_IMAGE_SEARCH: string = '/api/artifacts/search/image'; // 修正为与后端对应的路径
  static readonly API_IMAGE_SEARCH_ALT: string = '/api/search/image'; // 添加备用端点

  // 收藏相关接口
  static readonly API_COLLECTIONS: string = '/api/user/collections';
  static readonly API_ADD_COLLECTION: string = '/api/collection/add';
  static readonly API_REMOVE_COLLECTION: string = '/api/collection/remove';

  // 点赞相关接口
  static readonly API_LIKES: string = '/api/user/likes';
  static readonly API_LIKE: string = '/api/like/add';
  static readonly API_UNLIKE: string = '/api/like/remove';
  static readonly API_LIKE_CHECK: string = '/api/like/check'; // 添加检查点赞状态的API

  // 评论相关接口
  static readonly API_COMMENTS: string = '/api/comments';
  static readonly API_ADD_COMMENT: string = '/api/comment/add';

  // 浏览历史相关接口
  static readonly API_BROWSE_HISTORY: string = '/api/user/browse-history';
  static readonly API_ADD_BROWSE_HISTORY: string = '/api/browse-history/add';
  static readonly API_DELETE_BROWSE_HISTORY: string = '/api/browse-history/'; // 删除单条记录
  static readonly API_DELETE_ALL_BROWSE_HISTORY: string = '/api/user/browse-history/all'; // 删除所有记录

  /**
   * 获取完整的API URL
   * @param path API路径
   * @returns 完整的API URL
   */
  static getFullUrl(path: string): string {
    return `${ApiConstants.SERVER_BASE_URL}${path}`;
  }

  /**
   * 获取服务器地址(兼容原有代码的方法)
   */
  static getServerUrl(): string {
    // 检测是否在模拟器中运行
    const isEmulator = true; // 这里应该有更好的检测方法
    if (isEmulator) {
      return ApiConstants.SERVER_BASE_URL;
    } else {
      return "http://127.0.0.1:8080"; // 预览环境使用回环地址
    }
  }

  /**
   * 健康检查API端点
   */
  static readonly API_HEALTH_CHECK: string = '/api/health';
}
