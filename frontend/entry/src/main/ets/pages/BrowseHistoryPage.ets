
import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import ApiConstants from '../common/constants/ApiConstants';
import { UserService } from '../common/utils/UserService';

// 浏览历史记录接口
interface BrowseHistory {
  id: number;
  artifactId: number;
  artifactName: string;  // 文物名称
  artifactImage: string; // 文物图片
  browseTime: string;    // 浏览时间
}

// HTTP错误类型定义
interface HttpError {
  code?: number;
  message?: string;
}

// API响应接口定义
interface ApiResponse {
  success: boolean;
  message?: string;
  data?: BrowseHistory[] | boolean | number | string | null;
}

// 路由参数接口
interface RouteParams {
  userId?: number | string;
}

@Entry
@Component
struct BrowseHistoryPage {
  @State browseHistoryList: BrowseHistory[] = [];
  @State isLoading: boolean = true;
  @State errorMsg: string = '';
  @State currentUserId: number = 0;
  @State showDeleteDialog: boolean = false;    // 控制删除确认对话框
  @State selectedHistoryId: number = -1;       // 当前选中的记录ID
  @State isDeleting: boolean = false;          // 删除操作中状态
  @State disableItemClick: boolean = false;    // 禁用列表项点击（用于防止删除按钮事件冒泡）
  @State lastClickTime: number = 0;            // 最近一次点击时间（用于防止重复点击）

  private httpRequest = http.createHttp();
  private userService: UserService = UserService.getInstance();

  aboutToAppear() {
    // 从路由参数或用户服务获取用户ID
    const params = router.getParams() as RouteParams;
    if (params && params.userId) {
      this.currentUserId = Number(params.userId);
    } else {
      this.currentUserId = this.userService.getCurrentUserId();
    }

    // 加载浏览历史数据
    this.loadBrowseHistory();
  }

  aboutToDisappear() {
    // 销毁HTTP请求对象
    if (this.httpRequest) {
      this.httpRequest.destroy();
    }
  }

  // 加载浏览历史
  loadBrowseHistory() {
    this.isLoading = true;
    this.errorMsg = '';

    // 构建API URL，包含用户ID
    const url = `${ApiConstants.getFullUrl(ApiConstants.API_BROWSE_HISTORY)}?userId=${this.currentUserId}`;

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          this.isLoading = false;

          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse = JSON.parse(resultStr);

              if (result.success && Array.isArray(result.data)) {
                this.browseHistoryList = result.data;
                console.info(`获取浏览历史成功，共${this.browseHistoryList.length}条记录`);
              } else {
                this.errorMsg = result.message || '获取浏览历史失败';
                console.error(`获取浏览历史失败: ${this.errorMsg}`);
              }
            } catch (e) {
              this.errorMsg = '解析数据失败';
              console.error(`解析浏览历史响应失败: ${e.toString()}`);
            }
          } else {
            this.errorMsg = err?.message || '网络请求失败';
            console.error(`获取浏览历史请求失败: ${this.errorMsg}`);
          }
        }
      );
    } catch (e) {
      this.isLoading = false;
      this.errorMsg = '网络连接异常';
      console.error(`发起浏览历史请求异常: ${e.toString()}`);
    }
  }
  // 删除单条浏览记录
  deleteHistory(id: number) {
    if (this.isDeleting) return;

    this.isDeleting = true;

    // 显示删除中提示
    promptAction.showToast({
      message: '正在删除...',
      duration: 1000
    });

    const url = `${ApiConstants.getFullUrl(ApiConstants.API_DELETE_BROWSE_HISTORY)}${id}?userId=${this.currentUserId}`;

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.DELETE,
          header: {
            'Content-Type': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          this.isDeleting = false;

          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse = JSON.parse(resultStr);

              if (result.success) {
                // 删除成功，从列表中移除该记录
                this.browseHistoryList = this.browseHistoryList.filter(item => item.id !== id);
                promptAction.showToast({
                  message: '删除成功',
                  duration: 2000
                });
              } else {
                promptAction.showToast({
                  message: result.message || '删除失败',
                  duration: 2000
                });
              }
            } catch (e) {
              promptAction.showToast({
                message: '处理响应失败',
                duration: 2000
              });
              console.error(`解析删除响应失败: ${e.toString()}`);
            }
          } else {
            promptAction.showToast({
              message: err?.message || '网络请求失败',
              duration: 2000
            });
            console.error(`删除请求失败: ${err?.message || '未知错误'}`);
          }
        }
      );
    } catch (e) {
      this.isDeleting = false;
      promptAction.showToast({
        message: '网络连接异常',
        duration: 2000
      });
      console.error(`发起删除请求异常: ${e.toString()}`);
    }
  }
  // 删除所有浏览记录
  deleteAllHistory() {
    if (this.isDeleting) return;

    this.isDeleting = true;

    // 显示清空中提示
    promptAction.showToast({
      message: '正在清空...',
      duration: 1000
    });

    const url = `${ApiConstants.getFullUrl(ApiConstants.API_DELETE_ALL_BROWSE_HISTORY)}?userId=${this.currentUserId}`;

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.DELETE,
          header: {
            'Content-Type': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          this.isDeleting = false;

          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse = JSON.parse(resultStr);

              if (result.success) {
                // 清空浏览历史列表
                this.browseHistoryList = [];
                promptAction.showToast({
                  message: '已清空全部浏览记录',
                  duration: 2000
                });
              } else {
                promptAction.showToast({
                  message: result.message || '操作失败',
                  duration: 2000
                });
              }
            } catch (e) {
              promptAction.showToast({
                message: '处理响应失败',
                duration: 2000
              });
              console.error(`解析清空响应失败: ${e.toString()}`);
            }
          } else {
            promptAction.showToast({
              message: err?.message || '网络请求失败',
              duration: 2000
            });
            console.error(`清空请求失败: ${err?.message || '未知错误'}`);
          }
        }
      );
    } catch (e) {
      this.isDeleting = false;
      promptAction.showToast({
        message: '网络连接异常',
        duration: 2000
      });
      console.error(`发起清空请求异常: ${e.toString()}`);
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
      Column() {        // 顶部导航栏
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
          Text('浏览历史')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          // 清空按钮（如果有历史记录）
          if (this.browseHistoryList.length > 0) {
            Button({ type: ButtonType.Normal }) {
              Text('清空')
                .fontSize(16)
                .fontColor('#FF4D4F')
            }            .height(40)
            .backgroundColor('transparent')
            .onClick(() => {
              // 临时禁用列表项的点击事件（防止事件冒泡）
              this.disableItemClick = true;

              promptAction.showDialog({
                title: '清空浏览记录',
                message: '确定要清空所有浏览记录吗？此操作无法恢复。',
                buttons: [
                  {
                    text: '取消',
                    color: '#999999'
                  },
                  {
                    text: '清空',
                    color: '#FF4D4F'
                  }
                ]              }).then(result => {
                if (result.index === 1) {
                  // 用户点击了清空按钮
                  this.deleteAllHistory();
                }

                // 恢复列表项的点击事件
                this.disableItemClick = false;
              });
            })
          } else {
            // 右侧占位，保持布局对称
            Button({ type: ButtonType.Normal }) {
              Text('')
            }
            .height(40)
            .width(40)
            .backgroundColor('transparent')
            .opacity(0)
          }
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
        } else if (this.errorMsg) {
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
                this.loadBrowseHistory();
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.browseHistoryList.length === 0) {
          // 暂无数据状态
          Column() {
            Image($r('app.media.app_icon'))
              .width(64)
              .height(64)
              .opacity(0.5)
              .margin({ bottom: 16 })
            Text('暂无浏览记录')
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
          // 浏览历史列表
          List() {
            ForEach(this.browseHistoryList, (history: BrowseHistory) => {              ListItem() {
              // 滑动删除控件
              Swiper() {
                // 浏览历史卡片
                Row() {
                  // 左侧：文物图片
                  Stack() {
                    if (history.artifactImage) {
                      Image(history.artifactImage)
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

                  // 右侧：文物名称和浏览时间
                  Column() {
                    // 文物名称
                    Text(history.artifactName || '未知文物')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    // 浏览时间
                    Text(`浏览时间：${this.formatDate(history.browseTime)}`)
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ top: 8 })                      // 操作按钮
                    Row() {                        Button({ type: ButtonType.Normal }) {
                      Text('删除')
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                    }
                    .height(35)  // 修改尺寸为原来的1.5倍，并且变为方形
                    .width(45)
                    .backgroundColor('#FF4D4F')
                    .borderRadius(15)
                    .onClick(() => {
                      // 临时禁用列表项的点击事件（防止事件冒泡）
                      this.disableItemClick = true;

                      // 显示删除确认对话框
                      promptAction.showDialog({
                        title: '删除浏览记录',
                        message: `确定要删除"${history.artifactName || '未知文物'}"的浏览记录吗？`,
                        buttons: [
                          {
                            text: '取消',
                            color: '#999999'
                          },
                          {
                            text: '删除',
                            color: '#FF4D4F'
                          }
                        ]                          }).then(result => {
                        // 恢复列表项的点击事件
                        this.disableItemClick = false;

                        if (result.index === 1) {
                          // 用户点击了删除按钮
                          this.deleteHistory(history.id);
                        }
                      });
                    })
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.End)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .padding({ left: 16 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({ radius: 4, color: '#0000001A', offsetX: 0, offsetY: 2 })                  .onClick(() => {
                  // 判断是否允许点击（防止删除按钮的事件冒泡）
                  if (!this.disableItemClick) {
                    // 防止重复点击（300ms内的点击被视为重复）
                    const now = Date.now();
                    if (now - this.lastClickTime > 300) {
                      this.lastClickTime = now;

                      // 点击跳转到文物详情页
                      router.pushUrl({
                        url: 'pages/ArtifactDetailPage',
                        params: {
                          artifactId: history.artifactId
                        }
                      });
                    }
                  }
                })
              }
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
