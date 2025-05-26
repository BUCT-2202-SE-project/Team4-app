import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import ApiConstants from '../common/constants/ApiConstants';
import { UserService } from '../common/utils/UserService';

// 定义HTTP错误类型
interface HttpError {
  code?: number;
  message?: string;
}

// 定义文物接口 - 与其他页面保持一致
interface Artifact {
  id: number;            // 使用id作为主键，与后端保持一致
  name: string;
  era: string;
  type: string;
  museum: string;
  description: string;
  imageUrl: string;
  likes: number;
  feature?: string;
  isCollected?: boolean; // 添加是否已收藏的标记
  isLiked?: boolean;     // 添加是否已点赞的标记
  // 兼容性字段，以防其他地方使用了artifactId
  artifactId?: number;
}

// 定义评论接口
interface Comment {
  commentId: number;
  content: string;
  publishTime: string;
  userId: number;
  username: string;
  reviewStatus?: string; // 添加审核状态字段
}

// 定义评论提交数据接口
interface CommentRequest {
  content: string;
  artifactId: number;
  userId: number;
}

// 替换索引签名，使用明确属性定义
interface CollectionResult {
  id?: number;
  success?: boolean;
  status?: string;
  count?: number;
  value?: string;
  // 其他可能的属性...
}

// 添加API响应接口定义，修复为更严格的类型以匹配后端
interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  hasLiked?: boolean;
}

// 添加浏览历史请求接口定义
interface BrowseHistoryRequest {
  userId: number;
  artifactId: number;
  browseTime?: string; // 可选，服务器端可自动生成时间
}

// 添加更具体的响应类型定义
interface BrowseHistoryResponse {
  success: boolean;
  message?: string;
}

interface LikeResponse {
  success: boolean;
  message?: string;
  count?: number; // 可能返回的最新点赞数
}

interface CollectionResponse {
  success: boolean;
  message?: string;
  id?: number; // 收藏ID
}

// 参数接口定义 - 支持多种可能的参数名，但以id为主
interface RouterParams {
  id?: string | number;             // 标准名称，与后端保持一致
  artifactId?: string | number;     // 兼容旧代码
  artifact_id?: string | number;    // 兼容snake_case命名
  artifact?: Artifact;              // 接收完整对象
  uri?: string;                     // 其他参数
}

// 添加收藏请求接口定义
interface CollectionRequest {
  userId: number;
  artifactId: number;
}

@Entry
@Component
struct ArtifactDetailPage {
  @State artifact: Artifact = {} as Artifact;
  @State comments: Comment[] = [];
  @State isLoading: boolean = true;
  @State isLoadingComments: boolean = true;
  @State errorMsg: string = '';
  @State isCollected: boolean = false; // 添加收藏状态
  @State isLiked: boolean = false;     // 添加点赞状态
  @State commentText: string = ''; // 添加评论文本状态
  @State isSubmittingComment: boolean = false; // 添加评论提交状态
  @State editingCommentId: number = -1; // 当前正在编辑的评论ID，-1表示没有编辑状态
  @State editingCommentText: string = ''; // 编辑状态下的评论文本
  @State isEditingComment: boolean = false; // 是否在编辑评论

  private artifactId: number = 0;
  private httpRequest = http.createHttp();
  private userService: UserService = UserService.getInstance(); // 使用用户服务
  private currentUserId: number = 2; // 当前用户ID，将从用户服务获取

  // 添加浏览记录相关变量
  private viewStartTime: number = 0; // 页面打开时间
  private viewThreshold: number = 30000; // 30秒阈值，单位毫秒
  private viewTimerID: number = -1; // 定时器ID
  private hasRecorded: boolean = false; // 是否已记录浏览历史

  aboutToAppear() {
    // 从用户服务获取当前用户ID
    this.currentUserId = this.userService.getCurrentUserId();

    // 获取路由参数中的文物ID - 增强健壮性
    const params = router.getParams() as RouterParams;
    console.info(`接收到的路由参数: ${JSON.stringify(params)}`);

    // 兼容多种可能的ID字段名
    let artifactIdValue: string | number | undefined = undefined;

    if (params) {
      // 替换不支持的动态索引访问方式，改为直接访问已知属性
      console.info(`参数类型: ${typeof params}`);

      // 直接打印已知可能存在的关键参数，避免使用Object.keys()和索引访问
      console.info(`参数 id: ${JSON.stringify(params.id)}`);
      console.info(`参数 artifactId: ${JSON.stringify(params.artifactId)}`);
      console.info(`参数 artifact_id: ${JSON.stringify(params.artifact_id)}`);
      console.info(`参数 artifact: ${JSON.stringify(params.artifact)}`);
      console.info(`参数 uri: ${JSON.stringify(params.uri)}`);

      // 优先检查标准的id字段
      if (params.id !== undefined) {
        artifactIdValue = params.id;
        console.info(`找到参数id: ${artifactIdValue}`);
      }
      // 其次检查完整文物对象
      else if (params.artifact && typeof params.artifact === 'object') {
        const artifactObj = params.artifact as Artifact;
        console.info(`找到完整的artifact对象: ${JSON.stringify(artifactObj)}`);

        if (artifactObj.id !== undefined) {
          artifactIdValue = artifactObj.id;
          console.info(`从artifact对象中提取id: ${artifactIdValue}`);

          // 如果找到了ID，使用对象的其他属性作为初始数据
          this.artifact = artifactObj;
        }
        // 兼容使用artifactId的情况
        else if (artifactObj.artifactId !== undefined) {
          artifactIdValue = artifactObj.artifactId;
          console.info(`从artifact对象中提取artifactId: ${artifactIdValue}`);

          // 如果找到了ID，使用对象的其他属性作为初始数据
          this.artifact = artifactObj;
        }
      }
      // 最后检查其他可能的ID命名
      else if (params.artifactId !== undefined) {
        artifactIdValue = params.artifactId;
        console.info(`找到参数artifactId: ${artifactIdValue}`);
      } else if (params.artifact_id !== undefined) {
        artifactIdValue = params.artifact_id;
        console.info(`找到参数artifact_id: ${artifactIdValue}`);
      }

      // 尝试从URL中提取ID (兼容/artifacts/123格式)
      if (artifactIdValue === undefined && params.uri) {
        const uriString = params.uri.toString();
        const matches = uriString.match(/\/artifacts\/(\d+)/);
        if (matches && matches[1]) {
          artifactIdValue = matches[1];
          console.info(`从URI路径提取ID: ${artifactIdValue}`);
        }
      }
    }

    // 处理找到的ID值
    if (artifactIdValue !== undefined) {
      // 转换为数字
      try {
        // 如果是字符串，尝试解析为整数
        if (typeof artifactIdValue === 'string') {
          this.artifactId = parseInt(artifactIdValue);
        } else {
          // 已经是数字类型
          this.artifactId = artifactIdValue as number;
        }
        console.info(`将加载文物详情，解析后ID: ${this.artifactId}`);

        // 加载数据
        this.loadArtifactDetail();
        this.loadComments();
        this.checkCollectionStatus();
        this.checkLikeStatus();

        // 设置浏览记录相关参数
        this.viewStartTime = Date.now();
        this.hasRecorded = false;

        // 设置定时器，当用户浏览时间超过阈值时记录浏览历史
        this.viewTimerID = setTimeout(() => {
          if (!this.hasRecorded && this.currentUserId > 0) {
            this.recordBrowseHistory();
          }
        }, 20000);

      } catch (e) {
        console.error(`解析文物ID失败: ${e.toString()}, 原始值: ${artifactIdValue}`);
        this.errorMsg = `无法识别文物ID: ${artifactIdValue}`;
        this.isLoading = false;
      }
    } else {
      console.error('未找到有效的文物ID参数');
      this.errorMsg = '未找到文物ID信息';
      this.isLoading = false;

      // 显示错误提示
      promptAction.showToast({
        message: '找不到文物ID，无法加载详情',
        duration: 3000
      });
    }
  }

  aboutToDisappear() {
    // 清除定时器
    if (this.viewTimerID !== -1) {
      clearTimeout(this.viewTimerID);
      this.viewTimerID = -1;
    }

    if (this.httpRequest) {
      this.httpRequest.destroy();
    }
  }
  // 记录浏览历史
  recordBrowseHistory() {
    if (this.hasRecorded || this.currentUserId <= 0 || this.artifactId <= 0) {
      return;
    }

    const url = ApiConstants.getFullUrl(ApiConstants.API_ADD_BROWSE_HISTORY);
    console.info(`开始记录浏览历史，用户ID: ${this.currentUserId}，文物ID: ${this.artifactId}`);

    try {
      // 构造请求数据
      const requestData: BrowseHistoryRequest = {
        userId: this.currentUserId,
        artifactId: this.artifactId
      };

      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(requestData),
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse<BrowseHistoryResponse> = JSON.parse(resultStr);

              if (result.success) {
                console.info('浏览历史记录成功');
                this.hasRecorded = true;
              } else {
                console.error('浏览历史记录失败: ' + (result.message || '未知错误'));
              }
            } catch (e) {
              console.error(`解析浏览历史响应失败: ${e.toString()}`);
            }
          } else {
            console.error(`记录浏览历史失败: ${err?.message || '未知错误'}`);
          }
        }
      );
    } catch (e) {
      console.error(`发起浏览历史请求异常: ${e.toString()}`);
    }
  }

  // 检查文物点赞状态
  checkLikeStatus() {
    const url = `${ApiConstants.getFullUrl(ApiConstants.API_LIKE_CHECK)}?artifactId=${this.artifactId}&userId=${this.currentUserId}`;

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse<boolean> = JSON.parse(resultStr);

              if (result.success) {
                this.isLiked = result.hasLiked || false;
                this.artifact.isLiked = this.isLiked;
                console.info(`文物点赞状态检查结果：${this.isLiked ? '已点赞' : '未点赞'}`);
              }
            } catch (e) {
              console.error(`解析点赞状态失败: ${e.toString()}`);
            }
          } else {
            console.error(`检查点赞状态失败: ${err?.message || '未知错误'}`);
          }
        }
      );
    } catch (e) {
      console.error(`发起点赞状态检查异常: ${e.toString()}`);
    }
  }

  // 点赞或取消点赞
  toggleLike() {
    const url = ApiConstants.getFullUrl(this.isLiked ? ApiConstants.API_UNLIKE : ApiConstants.API_LIKE);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          extraData: JSON.stringify({
            artifactId: this.artifactId,
            userId: this.currentUserId
          }),
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse<LikeResponse> = JSON.parse(resultStr);

              if (result.success) {
                // 更新点赞状态
                this.isLiked = !this.isLiked;
                this.artifact.isLiked = this.isLiked;

                // 无论后端是否返回点赞数，都直接查询文物详情获取最新点赞数
                this.getLatestLikeCount();

                promptAction.showToast({
                  message: this.isLiked ? '点赞成功' : '取消点赞成功',
                  duration: 2000
                });
              } else {
                promptAction.showToast({
                  message: result.message || '操作失败',
                  duration: 2000
                });                console.error(`点赞操作失败: ${result.message || '未知错误'}`);
              }
            } catch (e) {
              console.error(`解析点赞操作响应失败: ${e.toString()}`);
              promptAction.showToast({
                message: '操作失败，请重试',
                duration: 2000
              });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            console.error(`点赞操作请求失败: ${errMsg}`);
            promptAction.showToast({
              message: '网络错误，请重试',
              duration: 2000
            });
          }
        }
      );
    } catch (e) {
      console.error(`发起点赞操作请求异常: ${e.toString()}`);
      promptAction.showToast({
        message: '网络连接异常',
        duration: 2000
      });
    }
  }

  // 获取最新的点赞数
  getLatestLikeCount() {
    const url = ApiConstants.getFullUrl(`/api/artifacts/likes/${this.artifactId}`);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse<number> = JSON.parse(resultStr);

              if (result.success && result.data !== undefined && typeof result.data === 'number') {
                // 只更新点赞数，不重新加载整个文物详情
                this.artifact.likes = result.data as number;
                console.info(`获取最新点赞数成功: ${this.artifact.likes}`);
              } else {
                console.error('获取最新点赞数失败，将重新加载文物详情');
                this.loadArtifactDetail();
              }
            } catch (e) {
              console.error(`解析点赞数响应失败: ${e.toString()}`);
              // 出错时回退到完整加载
              this.loadArtifactDetail();
            }
          } else {
            console.error(`获取最新点赞数请求失败: ${err?.message || '未知错误'}`);
            // 出错时回退到完整加载
            this.loadArtifactDetail();
          }
        }
      );
    } catch (e) {
      console.error(`发起获取点赞数请求异常: ${e.toString()}`);
      // 出错时回退到完整加载
      this.loadArtifactDetail();
    }
  }

  // 检查文物是否已收藏
  checkCollectionStatus() {
    // 构建API URL，增加userId参数
    const url = ApiConstants.getFullUrl(`/api/collection/check?artifactId=${this.artifactId}&userId=${this.currentUserId}`);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              console.info(`收藏状态检查响应: ${resultStr}`);

              // 修复: 添加明确的类型注解
              const result: ApiResponse<boolean> = JSON.parse(resultStr);
              if (result.success) {
                this.isCollected = result.data as boolean || false;
                console.info(`收藏状态检查结果: ${this.isCollected ? '已收藏' : '未收藏'}`);
              }
            } catch (e) {
              console.error(`解析收藏状态失败: ${e.toString()}`);
            }
          } else {
            console.error(`检查收藏状态失败: ${err?.message || '未知错误'}`);
          }
        }
      );
    } catch (e) {
      console.error(`发起收藏状态检查异常: ${e.toString()}`);
    }
  }

  // 添加或移除收藏
  toggleCollection() {
    const url = ApiConstants.getFullUrl(this.isCollected ? ApiConstants.API_REMOVE_COLLECTION : ApiConstants.API_ADD_COLLECTION);

    try {
      // 构建请求数据，确保包含userId
      const requestData: CollectionRequest = {
        userId: this.currentUserId, // 添加用户ID
        artifactId: this.artifactId
      };

      console.info(`发起${this.isCollected ? '取消' : '添加'}收藏请求：userId=${requestData.userId}, artifactId=${requestData.artifactId}`);

      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token' // TODO: 添加实际token
          },
          extraData: JSON.stringify(requestData), // 传递完整数据对象
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              // 修复: 添加明确的类型注解
              const result: ApiResponse<CollectionResponse> = JSON.parse(resultStr);

              if (result.success) {
                this.isCollected = !this.isCollected;
                promptAction.showToast({
                  message: this.isCollected ? '收藏成功' : '取消收藏成功',
                  duration: 2000
                });
              } else {
                promptAction.showToast({
                  message: result.message || '操作失败',
                  duration: 2000
                });
              }
            } catch (e) {
              console.error(`解析收藏操作响应失败: ${e.toString()}`);
              promptAction.showToast({
                message: '操作失败，请重试',
                duration: 2000
              });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            console.error(`收藏操作请求失败: ${errMsg}`);
            promptAction.showToast({
              message: '网络错误，请重试',
              duration: 2000
            });
          }
        }
      );
    } catch (e) {
      console.error(`发起收藏操作请求异常: ${e.toString()}`);
      promptAction.showToast({
        message: '网络连接异常',
        duration: 2000
      });
    }
  }

  // 加载文物详情 - 增强错误处理
  loadArtifactDetail() {
    this.isLoading = true;

    // 验证ID
    if (!this.artifactId || this.artifactId <= 0) {
      this.errorMsg = '无效的文物ID: ' + this.artifactId;
      this.isLoading = false;
      return;
    }

    const url = ApiConstants.getFullUrl(`${ApiConstants.API_ARTIFACT_DETAIL}${this.artifactId}`);
    console.info(`请求文物详情: ${url}, 文物ID: ${this.artifactId}`);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              console.info(`收到文物详情响应: ${data.result}`);
              const resultStr = data.result ? data.result.toString() : '{}';

              // 修改：首先尝试将响应解析为文物对象
              try {
                // 直接解析为文物对象
                const directArtifact: Artifact = JSON.parse(resultStr);

                // 检查是否是有效的文物对象 (至少有id和name)
                if (directArtifact && directArtifact.id !== undefined && directArtifact.name) {
                  console.info(`直接解析文物对象成功: ${directArtifact.name}`);
                  this.artifact = directArtifact;
                  this.isLoading = false;
                  return;
                }
              } catch (directParseError) {
                // 如果直接解析失败，继续尝试解析为API响应格式
                console.warn(`直接解析文物对象失败，尝试解析为API响应格式: ${directParseError}`);
              }

              // 后备方案：尝试解析为API包装格式 {success: boolean, data: Artifact}
              const apiResponse: ApiResponse<Artifact> = JSON.parse(resultStr);

              // 检查API响应中是否包含成功标志和有效数据
              if (apiResponse.success && apiResponse.data) {
                // 从响应的data字段中提取文物对象
                this.artifact = apiResponse.data;

                // 输出完整的文物对象信息，特别是图片URL
                console.info(`解析文物详情成功，完整数据: ${JSON.stringify(this.artifact)}`);
                console.info(`图片URL: ${this.artifact.imageUrl || '未提供图片URL'}`);

                // 如果后端API直接返回了收藏状态，更新isCollected
                if (this.artifact.isCollected !== undefined) {
                  this.isCollected = this.artifact.isCollected;
                }

                console.info(`解析文物详情成功: ${this.artifact.name}`);
              } else {
                // 如果API响应中没有有效数据，显示错误
                this.errorMsg = apiResponse.message || '未找到文物信息';
                console.error(`API返回错误: ${this.errorMsg}`);
              }
            } catch (e) {
              console.error(`解析文物详情失败: ${e.toString()}`);
              this.errorMsg = `解析文物详情失败: ${e.toString()}`;
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            console.error(`请求文物详情失败: ${errMsg}, 响应码: ${respCode}`);
            this.errorMsg = `网络请求失败: ${errMsg}, 响应码: ${respCode}`;
          }
          this.isLoading = false;
        }
      );
    } catch (e) {
      console.error(`发起文物详情请求异常: ${e.toString()}`);
      this.errorMsg = `发起请求异常: ${e.toString()}`;
      this.isLoading = false;
    }
  }

  // 加载评论
  loadComments() {
    this.isLoadingComments = true;
    // 修改URL格式，使用查询参数格式与后端API匹配，并传递当前用户ID
    const url = ApiConstants.getFullUrl(`${ApiConstants.API_COMMENTS}?artifactId=${this.artifactId}&userId=${this.currentUserId}`);

    console.info(`请求评论: ${url}`);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              console.info(`收到评论响应: ${data.result}`);
              const resultStr = data.result ? data.result.toString() : '[]';
              this.comments = JSON.parse(resultStr);
              console.info(`解析评论成功，获取了${this.comments.length}条评论`);
            } catch (e) {
              console.error(`解析评论失败: ${e.toString()}`);
              // 不显示错误信息，只在控制台记录
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            console.error(`请求评论失败: ${errMsg}, 响应码: ${respCode}`);
            // 不显示错误信息，只在控制台记录
          }
          this.isLoadingComments = false;
        }
      );
    } catch (e) {
      console.error(`发起评论请求异常: ${e.toString()}`);
      this.isLoadingComments = false;
    }
  }

  // 添加提交评论的方法
  submitComment() {
    if (!this.commentText || this.commentText.trim() === '') {
      promptAction.showToast({
        message: '请输入评论内容',
        duration: 2000
      });
      return;
    }

    if (this.isSubmittingComment) {
      return; // 避免重复提交
    }

    this.isSubmittingComment = true;
    const url = ApiConstants.getFullUrl(ApiConstants.API_COMMENTS);

    // 构建评论数据
    const commentData: CommentRequest = {
      content: this.commentText.trim(),
      artifactId: this.artifactId,
      userId: this.currentUserId // 修改：使用当前用户ID，而不是硬编码的值
    };

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer token' // 实际项目中应该使用有效的token
          },
          extraData: JSON.stringify(commentData),
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          this.isSubmittingComment = false;

          if (!err && (data.responseCode === 200 || data.responseCode === 201)) {
            try {
              console.info(`评论提交成功: ${data.result}`);
              promptAction.showToast({
                message: '评论发表成功，等待审核',
                duration: 2000
              });

              // 清空评论文本
              this.commentText = '';

              // 重新加载评论列表
              this.loadComments();
            } catch (e) {
              console.error(`解析评论提交响应失败: ${e.toString()}`);
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            console.error(`评论提交失败: ${errMsg}, 响应码: ${respCode}`);

            promptAction.showToast({
              message: '评论提交失败，请稍后重试',
              duration: 2000
            });
          }
        }
      );
    } catch (e) {
      console.error(`发起评论提交异常: ${e.toString()}`);
      this.isSubmittingComment = false;

      promptAction.showToast({
        message: '评论提交异常，请检查网络连接',
        duration: 2000
      });
    }
  }

  // 添加删除评论方法
  deleteComment(commentId: number) {
    const url = ApiConstants.getFullUrl(`${ApiConstants.API_COMMENTS}/${commentId}`);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.DELETE,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token' // 实际项目中应该使用有效的token
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 204) {
            // 删除成功，状态码204表示No Content
            console.info(`评论删除成功, ID: ${commentId}`);

            // 从列表中移除该评论
            this.comments = this.comments.filter(item => item.commentId !== commentId);

            promptAction.showToast({
              message: '评论已删除',
              duration: 2000
            });
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            console.error(`删除评论失败: ${errMsg}, 响应码: ${respCode}`);

            promptAction.showToast({
              message: '删除评论失败，请重试',
              duration: 2000
            });
          }
        }
      );
    } catch (e) {
      console.error(`发起删除评论请求异常: ${e.toString()}`);

      promptAction.showToast({
        message: '网络异常，请重试',
        duration: 2000
      });
    }
  }

  // 添加编辑评论的方法
  startEditComment(comment: Comment) {
    this.editingCommentId = comment.commentId;
    this.editingCommentText = comment.content;
    this.isEditingComment = true;
  }

  // 取消编辑评论
  cancelEditComment() {
    this.editingCommentId = -1;
    this.editingCommentText = '';
    this.isEditingComment = false;
  }

  // 保存编辑后的评论
  saveEditedComment() {
    if (!this.editingCommentText || this.editingCommentText.trim() === '') {
      promptAction.showToast({
        message: '评论内容不能为空',
        duration: 2000
      });
      return;
    }

    const url = ApiConstants.getFullUrl(`${ApiConstants.API_COMMENTS}/${this.editingCommentId}`);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.PUT,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token' // 实际项目中应该使用有效的token
          },
          extraData: JSON.stringify({
            content: this.editingCommentText.trim()
          }),
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              console.info(`评论编辑成功: ${data.result}`);
              const resultStr = data.result ? data.result.toString() : '{}';
              const updatedComment: Comment = JSON.parse(resultStr);

              // 更新本地评论列表
              this.comments = this.comments.map(item => {
                if (item.commentId === this.editingCommentId) {
                  return updatedComment;
                }
                return item;
              });

              promptAction.showToast({
                message: '评论已更新，等待审核',
                duration: 2000
              });

              // 重置编辑状态
              this.cancelEditComment();
            } catch (e) {
              console.error(`解析评论编辑响应失败: ${e.toString()}`);

              promptAction.showToast({
                message: '评论更新失败，请重试',
                duration: 2000
              });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            console.error(`评论编辑失败: ${errMsg}, 响应码: ${respCode}`);

            promptAction.showToast({
              message: '评论更新失败，请重试',
              duration: 2000
            });
          }
        }
      );
    } catch (e) {
      console.error(`发起评论编辑请求异常: ${e.toString()}`);

      promptAction.showToast({
        message: '网络异常，请重试',
        duration: 2000
      });
    }
  }

  // 格式化日期显示
  formatDate(dateString: string): string {
    if (!dateString) return '';
    try {
      const date = new Date(dateString);
      return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
    } catch (e) {
      return dateString;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Button({ type: ButtonType.Normal }) {
          // 替换为文字按钮，因为图标资源不存在
          Text('←')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
        }
        .height(40)
        .width(40)
        .backgroundColor('transparent')
        .onClick(() => {
          router.back();
        })

        // 标题
        Text(this.isLoading ? '文物详情' : this.artifact.name || '文物详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 右侧占位，使用透明按钮保持布局对称
        Button({ type: ButtonType.Normal }) {
          Text('')
        }
        .height(40)
        .width(40)
        .backgroundColor('transparent')
        .opacity(0)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 主体内容区域
      Scroll() {
        Column() {
          if (this.isLoading) {
            // 加载中显示
            Column() {
              LoadingProgress()
                .width(50)
                .height(50)
              Text('加载中...')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
            .height(300)
            .width('100%')
            .justifyContent(FlexAlign.Center)
          } else if (this.errorMsg !== '') {
            // 错误信息
            Column() {
              Text(this.errorMsg)
                .fontSize(16)
                .fontColor('#FF0000')
            }
            .height(300)
            .width('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            // 文物详情展示
            Column() {              // 文物图片
              Stack() {
                // 无条件显示图片，即使imageUrl可能为空，也尝试加载
                Image(this.artifact.imageUrl)
                  .width('100%')
                  .height(240)
                  .objectFit(ImageFit.Cover)
                  .onError(() => {
                    console.error(`图片加载失败: ${this.artifact.imageUrl}`);
                  })
              }
              .width('100%')

              // 文物基本信息
              Column() {
                // 文物名称
                Text(this.artifact.name || '')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 16, bottom: 12 })
                // 基本信息栏1 - 年代和类型
                Row() {
                  // 年代
                  Column() {
                    Text('年代')
                      .fontSize(14)
                      .fontColor('#999999')
                    Text(this.artifact.era || '未知')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Center)

                  Divider()
                    .vertical(true)
                    .height(30)
                    .color('#EEEEEE')

                  // 类型
                  Column() {
                    Text('类型')
                      .fontSize(14)
                      .fontColor('#999999')
                    Text(this.artifact.type || '未知')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Center)

                  Divider()
                    .vertical(true)
                    .height(30)
                    .color('#EEEEEE')

                  // 点赞数
                  Column() {
                    Text('点赞')
                      .fontSize(14)                      .fontColor('#999999')
                    Text(this.artifact.likes?.toString() || '0')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Center)
                }
                .width('100%')
                .padding({ top: 16, bottom: 16 })
                .backgroundColor('#F9F9F9')
                .borderRadius(8)
                .margin({ bottom: 8 })

                // 基本信息栏2 - 博物馆
                Row() {
                  // 博物馆
                  Column() {
                    Text('博物馆')
                      .fontSize(14)
                      .fontColor('#999999')
                    Text(this.artifact.museum || '未知')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 4 })                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding({ top: 12, bottom: 12, left: 16, right: 16 })
                .backgroundColor('#F9F9F9')
                .borderRadius(8)
                .margin({ bottom: 12 })

                // 详细介绍标题
                Text('详细介绍')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 8, bottom: 8 })
                  .alignSelf(ItemAlign.Start)

                // 详细介绍内容
                Text(this.artifact.description || '暂无介绍')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 24 })
                  .alignSelf(ItemAlign.Start)

                // 评论区标题
                Text('评论区')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 8, bottom: 16 })
                  .alignSelf(ItemAlign.Start)

                // 评论列表
                if (this.isLoadingComments) {
                  // 加载中显示
                  Column() {
                    LoadingProgress()
                      .width(30)
                      .height(30)
                    Text('加载评论中...')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ top: 8 })
                  }
                  .width('100%')
                  .padding({ top: 20, bottom: 20 })
                  .justifyContent(FlexAlign.Center)
                } else if (this.comments.length === 0) {
                  // 无评论显示
                  Column() {
                    Text('暂无评论')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .padding({ top: 20, bottom: 20 })
                  .justifyContent(FlexAlign.Center)
                } else {
                  // 评论列表
                  Column() {
                    ForEach(this.comments, (comment: Comment) => {
                      Column() {
                        // 评论者和时间
                        Row() {
                          Text(comment.username || '匿名用户')
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                          Text(this.formatDate(comment.publishTime))
                            .fontSize(14)
                            .fontColor('#999999')
                            .margin({ left: 8 })

                          // 审核状态标签 - 修改为更明显的待审核标签
                          if (comment.userId === this.currentUserId && comment.reviewStatus === '未通过') {
                            Text('待审核')
                              .fontSize(12)
                              .fontColor('#FFFFFF')
                              .backgroundColor('#FF9800')
                              .borderRadius(4)
                              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                              .margin({ left: 8 })
                          }
                        }
                        .width('100%')
                        .justifyContent(FlexAlign.SpaceBetween)
                        .margin({ bottom: 8 })

                        // 评论内容
                        Text(comment.content || '')
                          .fontSize(15)
                          .fontColor('#333333')
                          .width('100%')

                        // 删除和编辑按钮
                        if (comment.userId === this.currentUserId) {
                          Row() {
                            Button({ type: ButtonType.Normal }) {
                              Text('删除')
                                .fontSize(14)
                                .fontColor('#FF0000')
                            }
                            .height(30)
                            .width(60)
                            .backgroundColor('#FFEEEE')
                            .borderRadius(15)
                            .onClick(() => {
                              this.deleteComment(comment.commentId);
                            })

                            // 添加编辑按钮
                            Button({ type: ButtonType.Normal }) {
                              Text('编辑')
                                .fontSize(14)
                                .fontColor('#4E86FF')
                            }
                            .height(30)
                            .width(60)
                            .backgroundColor('#E6F0FF')
                            .borderRadius(15)
                            .margin({ left: 8 })
                            .onClick(() => {
                              this.startEditComment(comment);
                            })
                          }
                          .margin({ top: 8 })
                        }
                      }
                      .width('100%')
                      .padding(16)
                      .backgroundColor('#F9F9F9')
                      .borderRadius(8)
                      .margin({ bottom: 12 })
                    })
                  }
                  .width('100%')
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
              .backgroundColor('#FFFFFF')            }
          }
        }
        .width('100%')      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部操作栏
      Row() {
        // 评论输入框 - 修改为双向绑定
        TextInput({
          placeholder: '写下你的评论...',
          text: this.commentText
        })
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .fontSize(14)
          .onChange((value: string) => {
            this.commentText = value;
          })

        // 添加发送按钮
        Button({ type: ButtonType.Normal }) {
          Row() {
            Text('发送')
              .fontSize(14)
              .fontColor('#FFFFFF')
          }
        }
        .height(40)
        .width(60)
        .margin({ left: 8 })
        .backgroundColor('#4E86FF')
        .borderRadius(20)
        .enabled(!this.isSubmittingComment)
        .onClick(() => {
          this.submitComment();
        })

        // 点赞按钮 - 根据点赞状态显示不同样式
        Button({ type: ButtonType.Normal }) {
          Row() {
            // 根据点赞状态显示不同的图标和颜色
            Text(this.isLiked ? '❤️' : '👍')
              .fontSize(18)
            Text(this.isLiked ? '已点赞' : '点赞')
              .fontSize(14)
              .fontColor(this.isLiked ? '#FF4D4F' : '#4E86FF')
              .margin({ left: 4 })
          }
        }
        .height(40)
        .margin({ left: 8 })
        .backgroundColor(this.isLiked ? '#FFEEEE' : '#F0F7FF')
        .borderRadius(20)
        .onClick(() => {
          this.toggleLike();
        })

        // 收藏按钮 - 根据收藏状态显示不同样式
        Button({ type: ButtonType.Normal }) {
          Row() {
            // 使用文字表情替代图标，根据收藏状态显示不同图标
            Text(this.isCollected ? '★' : '☆')
              .fontSize(18)
              .fontColor(this.isCollected ? '#FFA500' : '#4E86FF')
            Text(this.isCollected ? '已收藏' : '收藏')
              .fontSize(14)
              .fontColor(this.isCollected ? '#FFA500' : '#4E86FF')
              .margin({ left: 4 })
          }
        }
        .height(40)
        .margin({ left: 8 })
        .backgroundColor(this.isCollected ? '#FFF8E6' : '#F0F7FF')
        .borderRadius(20)
        .onClick(() => {
          this.toggleCollection();
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderColor('#EEEEEE')
      .borderWidth({ top: 1 })

      // 添加编辑评论的弹窗
      if (this.isEditingComment) {
        Column() {
          // 弹窗标题
          Text('编辑评论')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 16 })

          // 评论编辑框
          TextArea({
            placeholder: '请输入评论内容',
            text: this.editingCommentText
          })
            .height(120)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
            .fontSize(16)
            .onChange((value: string) => {
              this.editingCommentText = value;
            })

          // 按钮行
          Row() {
            // 取消按钮
            Button({ type: ButtonType.Normal }) {
              Text('取消')
                .fontSize(16)
                .fontColor('#999999')
            }
            .height(40)
            .layoutWeight(1)
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .margin({ right: 8 })
            .onClick(() => {
              this.cancelEditComment();
            })

            // 确认按钮
            Button({ type: ButtonType.Normal }) {
              Text('保存')
                .fontSize(16)
                .fontColor('#FFFFFF')
            }
            .height(40)
            .layoutWeight(1)
            .backgroundColor('#4E86FF')
            .borderRadius(20)
            .margin({ left: 8 })
            .onClick(() => {
              this.saveEditedComment();
            })
          }
          .width('100%')
          .margin({ top: 16 })
        }
        .width('90%')
        .padding(24)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 6, color: '#00000020', offsetX: 0, offsetY: 2 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}