
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

// 定义文物接口
interface Artifact {
  id: number; // 修改：使用id而不是artifactId，与后端实体类保持一致
  artifactId?: number ; // 保留备用，以防其他地方使用
  name: string;
  era: string;
  type: string;
  museum: string;
  description: string;
  imageUrl: string;
  likes: number;
  feature?: string;
}


// 添加API响应接口定义
interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  code?: number;
}


@Entry
@Component
struct MyCollectionsPage {
  @State collections: Array<Artifact> = [];
  @State isLoading: boolean = true;
  @State errorMsg: string = '';
  @State userId: number = 0;  // 添加用户ID状态

  private httpRequest = http.createHttp();
  private userService: UserService = UserService.getInstance();

  aboutToAppear() {
    // 获取路由参数中的userId
    const params = router.getParams() as Record<string, number | string>;
    if (params && params.userId) {
      // 如果路由参数中有userId，则使用该参数
      this.userId = params.userId as number;
      console.info(`从路由参数获取到用户ID: ${this.userId}`);
    } else {
      // 否则从用户服务中获取userId
      this.userId = this.userService.getCurrentUserId();
      console.info(`从用户服务获取到用户ID: ${this.userId}`);
    }

    this.loadCollections();
  }

  aboutToDisappear() {
    if (this.httpRequest) {
      this.httpRequest.destroy();
    }
  }

  // 加载收藏的文物
  loadCollections() {
    this.isLoading = true;
    this.errorMsg = '';

    // 构建API URL - 添加用户ID参数
    const url = `${ApiConstants.getFullUrl(ApiConstants.API_COLLECTIONS)}?userId=${this.userId}`;

    console.info(`开始请求收藏文物数据，URL: ${url}，用户ID: ${this.userId}`);
    promptAction.showToast({
      message: '正在加载收藏数据...',
      duration: 1500
    });

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer token' // TODO: 添加实际token
          },
          connectTimeout: 30000, // 30秒连接超时
          readTimeout: 30000     // 30秒读取超时
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              console.info(`成功接收到响应，状态码: ${data.responseCode}`);

              const resultStr = data.result ? data.result.toString() : '{}';
              console.info(`转换为字符串: ${resultStr.substring(0, 100)}...`); // 只记录前100个字符避免日志过长

              // 修改: 先解析为标准 API 响应格式
              const apiResponse: ApiResponse<Array<Artifact>> = JSON.parse(resultStr);

              if (apiResponse.success) {
                if (apiResponse.data && Array.isArray(apiResponse.data)) {
                  this.collections = apiResponse.data;
                  console.info(`成功解析为数组，包含${this.collections.length}个收藏项目`);

                  if (this.collections.length === 0) {
                    console.warn('获取到空数组，没有收藏数据');
                    this.errorMsg = '暂无收藏数据';
                    promptAction.showToast({
                      message: '暂无收藏数据',
                      duration: 2000
                    });
                  } else {
                    promptAction.showToast({
                      message: `已加载${this.collections.length}个收藏文物`,
                      duration: 2000
                    });
                  }
                } else {
                  console.error(`API返回的数据不是数组: ${typeof apiResponse.data}`);
                  this.errorMsg = '数据格式错误：返回的不是数组';
                  this.collections = [];
                  promptAction.showToast({
                    message: '数据格式错误',
                    duration: 2000
                  });
                }
              } else {
                console.error(`API请求失败: ${apiResponse.message}`);
                this.errorMsg = apiResponse.message || '获取数据失败';
                this.collections = [];
                promptAction.showToast({
                  message: this.errorMsg,
                  duration: 2000
                });
              }
            } catch (e) {
              console.error(`解析响应失败: ${e.toString()}`);
              console.error(`原始响应数据: ${data.result?.toString().substring(0, 200) || '空'}`);
              this.errorMsg = `解析数据失败: ${e.toString()}`;
              this.collections = [];
              promptAction.showToast({
                message: '解析数据失败',
                duration: 2000
              });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            console.error(`请求失败: ${errMsg}, 响应码: ${respCode}`);
            this.errorMsg = `网络请求失败: ${errMsg}, 响应码: ${respCode}`;
            this.collections = [];
            promptAction.showToast({
              message: `网络错误: ${errMsg}`,
              duration: 3000
            });
          }
          this.isLoading = false;
        }
      );
    } catch (e) {
      console.error(`发起请求异常: ${e.toString()}`);
      this.errorMsg = `发起请求异常: ${e.toString()}`;
      this.isLoading = false;
      this.collections = [];
      promptAction.showToast({
        message: '网络连接异常',
        duration: 3000
      });
    }
  }

  // 取消收藏
  removeFromCollection(artifactId: number) {
    const url = ApiConstants.getFullUrl(ApiConstants.API_REMOVE_COLLECTION);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token' // TODO: 添加实际token
          },
          extraData: JSON.stringify({
            userId: this.userId,
            artifactId: artifactId // 这里保持artifactId的使用
          }),
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              // 修改: 解析为标准API响应
              const result: ApiResponse<boolean> = JSON.parse(resultStr);

              if (result.success) {
                promptAction.showToast({
                  message: '取消收藏成功',
                  duration: 2000
                });

                // 从列表中移除
                this.collections = this.collections.filter(item => item.id !== artifactId);
              } else {
                promptAction.showToast({
                  message: result.message || '取消收藏失败',
                  duration: 2000
                });
              }
            } catch (e) {
              console.error(`解析取消收藏响应失败: ${e.toString()}`);
              promptAction.showToast({
                message: '操作失败，请重试',
                duration: 2000
              });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            console.error(`取消收藏请求失败: ${errMsg}`);
            promptAction.showToast({
              message: '网络错误，请重试',
              duration: 2000
            });
          }
        }
      );
    } catch (e) {
      console.error(`发起取消收藏请求异常: ${e.toString()}`);
      promptAction.showToast({
        message: '网络连接异常',
        duration: 2000
      });
    }
  }

  // 修复方法，确保finalId是确定的number类型
  navigateToDetail(artifact: Artifact) {
    // 打印接收到的参数信息
    console.info(`准备跳转详情，文物: ${artifact.name}`);
    console.info(`参数 artifactId=${artifact.artifactId}, id=${artifact.id}`);
    console.info(`所有可用属性: ${Object.keys(artifact).join(', ')}`);
    
    // 尝试各种方式获取ID
    let finalId: number = 0; // 初始化为默认值
    
    // 按优先级尝试获取不同来源的ID
    if (artifact.id) {
      finalId = artifact.id;
    } else if (artifact.artifactId) {
      finalId = artifact.artifactId;
    } else if (artifact.name) {
      // 尝试从名称中提取数字
      const nameMatch = artifact.name.match(/\d+/);
      if (nameMatch) {
        finalId = parseInt(nameMatch[0]);
        console.info(`从名称[${artifact.name}]中提取到ID: ${finalId}`);
      }
    }
    
    console.info(`准备跳转到文物详情，最终确定的ID: ${finalId}`);
    
    if (finalId > 0) { // 确保ID有效
      router.pushUrl({
        url: 'pages/ArtifactDetailPage',
        params: {
          artifactId: finalId  // 现在finalId是确定的number类型
        }
      });
      console.info(`已发起跳转请求，参数artifactId=${finalId}`);
    } else {
      console.error(`无法找到文物ID，无法跳转: ${artifact.name}`);
      promptAction.showToast({
        message: '无法查看详情，请联系管理员',
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Button({ type: ButtonType.Normal }) {
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
        Text('我的收藏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 右侧占位，保持布局对称
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

      // 主体内容
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
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.collections.length === 0) {
        // 无数据显示
        Column() {
          Text('暂无收藏文物')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 16 })

          Button('去文物列表看看')
            .fontSize(16)
            .height(40)
            .backgroundColor('#4E86FF')
            .borderRadius(20)
            .onClick(() => {
              router.replaceUrl({
                url: 'pages/ArtifactListPage'
              });
            })
        }
        .height('80%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 收藏列表
        List() {
          ForEach(this.collections, (item: Artifact) => {
            ListItem() {
              Column() {
                Row() {
                  // 文物图片（或占位图）
                  Stack() {
                    if (item.imageUrl) {
                      Image(item.imageUrl)
                        .width(120)
                        .height(120)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(8)
                    } else {
                      // 占位图
                      Column() {
                      }
                      .width(120)
                      .height(120)
                      .backgroundColor('#DDDDDD')
                      .borderRadius(8)
                    }
                  }
                  .margin({ right: 16 })

                  // 文物信息
                  Column() {
                    Text(item.name || '未命名文物')
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .margin({ bottom: 8 })

                    Row() {
                      Text('朝代: ')
                        .fontSize(14)
                        .fontColor('#666666')
                      Text(item.era || '未知')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                    }
                    .margin({ bottom: 6 })
                    .width('100%')
                    Row() {
                      Text('类型: ')
                        .fontSize(14)
                        .fontColor('#666666')
                      Text(item.type || '未知')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                    }
                    .margin({ bottom: 6 })
                    .width('100%')

                    Row() {
                      Text('博物馆: ')
                        .fontSize(14)
                        .fontColor('#666666')
                      Text(item.museum || '未知')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                    }
                    .margin({ bottom: 6 })
                    .width('100%')

                    // 操作按钮
                    Row() {
                      Button('取消收藏')
                        .fontSize(12)
                        .fontColor('#FF4D4F')
                        .backgroundColor('transparent')
                        .height(28)
                        .border({
                          color: '#FF4D4F',
                          width: 1
                        })
                        .borderRadius(14)
                        .onClick(() => {
                          this.removeFromCollection(item.artifactId ?? 0);
                        })

                      Button('查看详情')
                        .fontSize(12)
                        .fontColor('#4E86FF')
                        .backgroundColor('transparent')
                        .height(28)
                        .margin({ left: 8 })
                        .border({
                          color: '#4E86FF',
                          width: 1
                        })
                        .borderRadius(14)
                        .onClick(() => {
                          // 使用统一的跳转方法
                          this.navigateToDetail(item);
                        })
                    }
                    .margin({ top: 8 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
              }
              .width('100%')
              .padding(16)
              .borderRadius(12)
              .backgroundColor('#FFFFFF')
              .onClick(() => {
                // 使用统一的跳转方法
                this.navigateToDetail(item);
              })
            }
            .margin({ bottom: 12 })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
