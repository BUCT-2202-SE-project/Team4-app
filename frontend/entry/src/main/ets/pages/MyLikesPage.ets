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
  artifactId: number;
  name: string;
  era: string;
  type: string;
  museum: string;
  description: string;
  imageUrl: string;
  likes: number;
  feature?: string;
  id?: number; // 添加可选的id属性，兼容不同接口
}

// 扩展文物接口，兼容下划线命名约定的字段
interface ExtendedArtifact extends Artifact {
  artifact_id?: number; // 可能存在的下划线风格命名的ID字段
}

// API响应接口定义
interface ApiResponse {
  success: boolean;
  message?: string;
  data?: boolean | number | string | Array<Artifact>;
}

// 文物项组件
@Component
struct ArtifactItem {
  private artifact: Artifact = {
    artifactId: 0,
    name: '',
    era: '',
    type: '',
    museum: '',
    description: '',
    imageUrl: '',
    likes: 0
  };
  private onItemClick: (artifact: Artifact) => void = () => {};
  private onUnlikeClick: (artifactId: number) => void = () => {};

  build() {
    Column() {
      Row() {
        // 文物图片（或占位图）
        Stack() {
          if (this.artifact.imageUrl) {
            Image(this.artifact.imageUrl)
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
          Text(this.artifact.name || '未命名文物')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })

          Row() {
            Text('朝代: ')
              .fontSize(14)
              .fontColor('#666666')
            Text(this.artifact.era || '未知')
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
            Text(this.artifact.type || '未知')
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
            Text(this.artifact.museum || '未知')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
          }
          .margin({ bottom: 6 })
          .width('100%')

          // 操作按钮
          Row() {
            Button() {
              Row() {
                Text('👍 ')
                  .fontSize(16)
                  .fontColor('#FF4D4F')
                Text('取消点赞')
                  .fontSize(12)
                  .fontColor('#FF4D4F')
              }
            }
            .backgroundColor('transparent')
            .height(28)
            .border({
              color: '#FF4D4F',
              width: 1
            })
            .borderRadius(14)
            .onClick(() => {
              this.onUnlikeClick(this.artifact.artifactId);
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
                this.onItemClick(this.artifact);
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
      this.onItemClick(this.artifact);
    })
  }
}

@Entry
@Component
struct MyLikesPage {
  @State likedArtifacts: Array<Artifact> = [];
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

    this.loadLikedArtifacts();
  }

  aboutToDisappear() {
    if (this.httpRequest) {
      this.httpRequest.destroy();
    }
  }

  // 加载点赞的文物
  loadLikedArtifacts() {
    this.isLoading = true;
    this.errorMsg = '';

    // 构建API URL - 添加用户ID参数
    const url = `${ApiConstants.getFullUrl(ApiConstants.API_LIKES)}?userId=${this.userId}`;

    console.info(`开始请求点赞文物数据，URL: ${url}，用户ID: ${this.userId}`);
    promptAction.showToast({
      message: '正在加载点赞数据...',
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

              const resultStr = data.result ? data.result.toString() : '[]';
              console.info(`转换为字符串: ${resultStr.substring(0, 100)}...`); // 只记录前100个字符避免日志过长

              const result: Array<Artifact> = JSON.parse(resultStr);
              if (Array.isArray(result)) {
                // 打印第一个对象的完整结构，帮助调试
                if(result.length > 0) {
                  console.info(`第一个点赞文物完整数据: ${JSON.stringify(result[0])}`);
                  console.info(`可用的属性: ${Object.keys(result[0]).join(', ')}`);
                }
                
                // 修复：避免使用未类型化的对象字面量
                this.likedArtifacts = result.map(item => {
                  // 不创建新对象，而是直接修改原始对象
                  // 尝试从各种可能的字段名获取ID
                  const rawData = JSON.stringify(item);
                  const match = rawData.match(/"artifact_id":(\d+)/);
                  const rawId = match ? parseInt(match[1]) : null;
                  
                  // 使用已定义的ID字段或从原始JSON提取的ID
                  const potentialId = item.id || item.artifactId || rawId;
                  
                  console.info(`文物[${item.name}] ID提取: artifactId=${item.artifactId}, id=${item.id}, 提取ID=${potentialId}`);
                  
                  // 直接修改原始对象，不创建拷贝
                  if (potentialId) {
                    item.id = potentialId;
                    item.artifactId = potentialId;
                    console.info(`文物[${item.name}] ID已更新: artifactId=${item.artifactId}, id=${item.id}`);
                  }
                  
                  return item;
                });
                console.info(`成功解析为数组，包含${this.likedArtifacts.length}个点赞项目`);

                if (this.likedArtifacts.length === 0) {
                  console.warn('获取到空数组，没有点赞数据');
                  this.errorMsg = '暂无点赞数据';
                  promptAction.showToast({
                    message: '暂无点赞数据',
                    duration: 2000
                  });
                } else {
                  promptAction.showToast({
                    message: `已加载${this.likedArtifacts.length}个点赞文物`,
                    duration: 2000
                  });
                }
              } else {
                console.error(`API返回的数据不是数组: ${typeof result}`);
                this.errorMsg = '数据格式错误：返回的不是数组';
                this.likedArtifacts = [];
                promptAction.showToast({
                  message: '数据格式错误',
                  duration: 2000
                });
              }
            } catch (e) {
              console.error(`解析响应失败: ${e.toString()}`);
              console.error(`原始响应数据: ${data.result?.toString().substring(0, 200) || '空'}`);
              this.errorMsg = `解析数据失败: ${e.toString()}`;
              this.likedArtifacts = [];
              promptAction.showToast({
                message: '解析数据失败',
                duration: 2000
              });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            let respBody = '';

            // 尝试获取响应体以查看详细错误信息
            if (data && data.result) {
              try {
                respBody = data.result.toString();
                console.error(`响应体: ${respBody}`);
              } catch (e) {
                console.error(`无法读取响应体: ${e.toString()}`);
              }
            }

            console.error(`请求失败: ${errMsg}, 响应码: ${respCode}, 响应体: ${respBody}`);
            this.errorMsg = `网络请求失败: ${errMsg}, 响应码: ${respCode}`;
            this.likedArtifacts = [];
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
      this.likedArtifacts = [];
      promptAction.showToast({
        message: '网络连接异常',
        duration: 3000
      });
    }
  }

  // 取消点赞
  unlikeArtifact(artifactId: number) {
    const url = ApiConstants.getFullUrl(ApiConstants.API_UNLIKE);

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
            artifactId: artifactId
          }),
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse = JSON.parse(resultStr);

              if (result.success) {
                promptAction.showToast({
                  message: '取消点赞成功',
                  duration: 2000
                });

                // 从列表中移除
                this.likedArtifacts = this.likedArtifacts.filter(item => item.artifactId !== artifactId);
              } else {
                promptAction.showToast({
                  message: result.message || '取消点赞失败',
                  duration: 2000
                });
              }
            } catch (e) {
              console.error(`解析取消点赞响应失败: ${e.toString()}`);
              promptAction.showToast({
                message: '操作失败，请重试',
                duration: 2000
              });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            console.error(`取消点赞请求失败: ${errMsg}`);
            promptAction.showToast({
              message: '网络错误，请重试',
              duration: 2000
            });
          }
        }
      );
    } catch (e) {
      console.error(`发起取消点赞请求异常: ${e.toString()}`);
      promptAction.showToast({
        message: '网络连接异常',
        duration: 2000
      });
    }
  }

  // 简化navigateToDetail方法，与评论页面保持一致
  navigateToDetail(artifact: Artifact) {
    // 直接硬编码ID从文物名称中获取
    // 这是一个临时方案，根据文物名称提取ID
    // 假设文物名称包含一个序号模式
    let artifactId: number | undefined = undefined;
    
    if (artifact.name) {
      // 从名称中提取数字作为ID
      const nameMatch = artifact.name.match(/\d+/);
      if (nameMatch) {
        artifactId = parseInt(nameMatch[0]);
        console.info(`从名称[${artifact.name}]中提取到ID: ${artifactId}`);
      }
    }
    
    // 尝试各种ID字段
    artifactId = artifact.artifactId || artifact.id || artifactId;
    
    console.info(`准备跳转到文物详情，最终确定的ID: ${artifactId}`);
    
    if (artifactId) {
      router.pushUrl({
        url: 'pages/ArtifactDetailPage',
        params: {
          artifactId: artifactId  // 与评论页面用同名参数
        }
      });
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
        Text('我的点赞')
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
      } else if (this.likedArtifacts.length === 0) {
        // 无数据显示
        Column() {
          Text('暂无点赞文物')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 16 })

          Button('去文物列表看看')
            .fontSize(16)
            .height(40)
            .backgroundColor('#4E86FF')
            .borderRadius(20)
            .onClick(() => {
              console.info('跳转到文物列表页');
              try {
                router.replaceUrl({
                  url: 'pages/ArtifactListPage'
                }).then(() => {
                  console.info('成功跳转到文物列表页');
                // }).catch((e) => {
                //   console.error(`跳转到文物列表页失败: ${JSON.stringify()}`);
                //   promptAction.showToast({
                //     message: '跳转失败，请重试',
                //     duration: 2000
                //   });
                });
              } catch (e) {
                console.error(`跳转出现异常: ${e instanceof Error ? e.message : JSON.stringify(e)}`);
                promptAction.showToast({
                  message: '跳转异常，请重试',
                  duration: 2000
                });
              }
            })
        }
        .height('80%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 点赞列表
        List() {
          ForEach(this.likedArtifacts, (item: Artifact) => {
            ListItem() {
              ArtifactItem({
                artifact: item,
                onItemClick: (artifact: Artifact) => {
                  this.navigateToDetail(artifact);
                },
                onUnlikeClick: (artifactId: number) => {
                  this.unlikeArtifact(artifactId);
                }
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