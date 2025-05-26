import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import ApiConstants from '../common/constants/ApiConstants';
import { UserService } from '../common/utils/UserService';

// 评论数据类型定义
interface UserComment {
  commentId: number;
  content: string;
  publishTime: string;
  reviewStatus: string;
  artifactId: number;
  artifactName: string; // 文物名称
  artifactImage: string; // 文物图片
}

// 路由参数接口
interface RouteParams {
  userId?: number | string;
}

// HTTP错误类型定义
interface HttpError {
  code?: number;
  message?: string;
}

@Entry
@Component
struct MyCommentsPage {
  @State comments: UserComment[] = [];
  @State isLoading: boolean = true;
  @State errorMsg: string = '';
  @State currentUserId: number = 2; // 默认用户ID为2
  private httpRequest = http.createHttp();
  private userService: UserService = UserService.getInstance();

  aboutToAppear() {
    // 从全局用户服务获取当前用户ID
    this.currentUserId = this.userService.getCurrentUserId();
    console.info(`当前用户ID: ${this.currentUserId}`);

    this.loadUserComments();
  }

  aboutToDisappear() {
    if (this.httpRequest) {
      this.httpRequest.destroy();
    }
  }

  // 加载用户评论
  loadUserComments() {
    this.isLoading = true;
    const url = ApiConstants.getFullUrl(`/api/comments/user/${this.currentUserId}`);

    console.info(`请求用户评论: ${url}`);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer token' // 实际项目中应该使用有效的token
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          this.isLoading = false;

          if (!err && data.responseCode === 200) {
            try {
              console.info(`收到用户评论响应: ${data.result}`);
              const resultStr = data.result ? data.result.toString() : '[]';
              this.comments = JSON.parse(resultStr);
              console.info(`解析用户评论成功，获取了${this.comments.length}条评论`);
            } catch (e) {
              console.error(`解析用户评论失败: ${e.toString()}`);
              this.errorMsg = '解析评论数据失败';
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            console.error(`请求用户评论失败: ${errMsg}, 响应码: ${respCode}`);
            this.errorMsg = '获取评论列表失败';
          }
        }
      );
    } catch (e) {
      console.error(`发起用户评论请求异常: ${e.toString()}`);
      this.isLoading = false;
      this.errorMsg = '网络请求异常';
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
    Stack({ alignContent: Alignment.Center }) {
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
          Text('我的评论')
            .fontSize(18)
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

        // 主体内容区域
        if (this.isLoading) {
          // 加载中状态
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 16 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.errorMsg !== '') {
          // 错误状态
          Column() {
            Image($r('app.media.app_icon'))
              .width(64)
              .height(64)
              .opacity(0.5)
              .margin({ bottom: 16 })
            Text(this.errorMsg)
              .fontSize(16)
              .fontColor('#FF4D4F')
            Button('重试')
              .margin({ top: 24 })
              .onClick(() => {
                this.errorMsg = '';
                this.loadUserComments();
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.comments.length === 0) {
          // 暂无评论状态
          Column() {
            Image($r('app.media.app_icon'))
              .width(64)
              .height(64)
              .opacity(0.5)
              .margin({ bottom: 16 })
            Text('暂无评论')
              .fontSize(16)
              .fontColor('#999999')
            Button('去浏览文物')
              .margin({ top: 24 })
              .onClick(() => {
                router.replaceUrl({
                  url: 'pages/ArtifactListPage'
                });
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          // 评论列表
          List() {
            ForEach(this.comments, (comment: UserComment) => {
              ListItem() {
                // 评论卡片
                Row() {
                  // 左侧：文物名称和图片
                  Column() {
                    // 文物名称
                    Text(comment.artifactName || '未知文物')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ bottom: 8 })

                    // 文物图片
                    Stack() {
                      if (comment.artifactImage) {
                        Image(comment.artifactImage)
                          .width(100)
                          .height(100)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(8)
                      } else {
                        // 占位图
                        Column() {
                          Text('暂无图片')
                            .fontSize(12)
                            .fontColor('#999999')
                        }
                        .width(100)
                        .height(100)
                        .backgroundColor('#F0F0F0')
                        .borderRadius(8)
                        .justifyContent(FlexAlign.Center)
                      }
                    }
                    .width(100)
                    .height(100)
                  }
                  .width(100)
                  .alignItems(HorizontalAlign.Start)

                  // 右侧：时间和评论内容
                  Column() {
                    // 时间和状态
                    Row() {
                      // 评论时间
                      Text(this.formatDate(comment.publishTime))
                        .fontSize(14)
                        .fontColor('#999999')

                      // 评论状态，更改标签样式和文字
                      if (comment.reviewStatus === '未通过') {
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
                    .margin({ bottom: 8 })

                    // 评论内容
                    Text(comment.content || '')
                      .fontSize(15)
                      .fontColor('#333333')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(3)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .padding({ left: 16 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({ radius: 4, color: '#0000001A', offsetX: 0, offsetY: 2 })
                .onClick(() => {
                  // 点击跳转到文物详情页
                  router.pushUrl({
                    url: 'pages/ArtifactDetailPage',
                    params: {
                      artifactId: comment.artifactId
                    }
                  });
                })
              }
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            })
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .divider({
            strokeWidth: 1,
            color: 'transparent',
            startMargin: 4,
            endMargin: 4
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}