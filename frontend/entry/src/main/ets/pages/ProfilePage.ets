import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import http from '@ohos.net.http';
import ApiConstants from '../common/constants/ApiConstants';
import { CommonTabBar } from '../common/components/CommonTabBar';
import { UserService } from '../common/utils/UserService';

interface User {
  userId: number;
  username: string;
  email: string;
  registerTime: string;
}

interface HttpError {
  code?: number;
  message?: string;
}

interface MenuItem {
  title: string;
  icon: Resource | string;
  route: string;
}

// 添加明确的接口类型定义
interface ApiResponse {
  success: boolean;
  message?: string;
  data?: User;
}

@Entry
@Component
struct ProfilePage {
  @State isLoggedIn: boolean = false;
  @State user: User = { userId: 0, username: '游客', email: '', registerTime: '' };
  @State currentUserId: number = 0;
  private httpRequest = http.createHttp();
  private userService: UserService = UserService.getInstance();
  
  // 菜单项定义
  private menuItems: MenuItem[] = [
    { title: '我的收藏', icon: '❤️', route: 'pages/MyCollectionsPage' },
    { title: '浏览历史', icon: '🕒', route: 'pages/BrowseHistoryPage' },
    { title: '我的评论', icon: '💬', route: 'pages/MyCommentsPage' },
    { title: '我的点赞', icon: '👍', route: 'pages/MyLikesPage' },
    { title: '系统设置', icon: '⚙️', route: 'pages/SettingsPage' }
  ];
  
  aboutToAppear() {
    // 从用户服务获取当前用户ID
    this.currentUserId = this.userService.getCurrentUserId();
    
    // 检查登录状态并获取用户信息
    this.checkLoginStatus();
  }
  
  // 添加onPageShow生命周期方法，当页面每次显示时都会触发
  onPageShow() {
    // 重新获取用户ID并刷新用户信息
    this.currentUserId = this.userService.getCurrentUserId();
    this.checkLoginStatus();
    console.info('ProfilePage onPageShow: 刷新用户信息');
  }
  
  aboutToDisappear() {
    this.httpRequest.destroy();
  }
  
  // 检查登录状态
  checkLoginStatus() {
    // 根据当前用户ID判断是否已登录
    this.isLoggedIn = this.currentUserId > 0;
    
    if (this.isLoggedIn) {
      this.getUserInfo();
    }
  }
  
  // 获取用户信息
  getUserInfo() {
    // 构建API URL，包含用户ID
    const url = ApiConstants.getFullUrl(`${ApiConstants.API_USER_INFO}/${this.currentUserId}`);
    
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
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              // 添加明确的类型标注
              const result: ApiResponse = JSON.parse(resultStr);
              
              if (result.success && result.data) {
                this.user = result.data;
                console.info(`获取用户信息成功: 用户ID=${this.user.userId}`);
              } else {
                console.error('获取用户信息失败: ' + (result.message || '未知错误'));
              }
            } catch (e) {
              console.error(`解析用户信息异常: ${e.toString()}`);
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            console.error(`获取用户信息请求失败: ${errMsg}`);
          }
        }
      );
    } catch (e) {
      console.error(`发起获取用户信息请求异常: ${e.toString()}`);
    }
  }
  
  // 退出登录
  logout() {
    // 清除登录状态和用户信息
    this.isLoggedIn = false;
    this.user = { userId: 0, username: '游客', email: '', registerTime: '' };
    this.currentUserId = 0;
    
    // 重置用户服务中的用户ID
    this.userService.resetUserId();
    
    // 跳转到登录页面
    router.pushUrl({
      url: 'pages/LoginPage'
    });
  }
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('个人中心')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
      
      // 主要内容区域包装在Scroll中，以确保内容可滚动，不会影响底部导航栏定位
      Scroll() {
        Column() {
          // 用户信息卡片
          Column() {
            Row() {
              // 头像
              Image($r('app.media.app_icon'))
                .width(80)
                .height(80)
                .borderRadius(40)
                .backgroundColor('#F0F0F0')
              
              // 用户名和注册时间
              Column() {
                Text(this.user.username)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 8 })
                
                Text(this.user.email || '')
                  .fontSize(14)
                  .fontColor('#666666')
                
                if (this.isLoggedIn) {
                  Row() {
                    Text(`用户ID: ${this.user.userId}`)
                      .fontSize(14)
                      .fontColor('#FF6A00')
                      .fontWeight(FontWeight.Bold)
                      .margin({ top: 4 })
                  }
                  
                  Text(this.user.registerTime ? `注册时间: ${this.user.registerTime}` : '')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16 })
            }
            .width('100%')
            .padding(16)
              if (this.isLoggedIn) {
              // 添加编辑个人资料按钮
              Button('编辑个人资料')
                .width('90%')
                .height(40)
                .borderRadius(20)
                .backgroundColor('#4E86FF')
                .fontColor(Color.White)
                .fontSize(14)
                .margin({ top: 16, bottom: 8 })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/UserProfileEditPage',
                    params: {
                      userId: this.currentUserId
                    }
                  });
                })
              
              Button('退出登录')
                .width('90%')
                .height(40)
                .borderRadius(20)
                .backgroundColor('#FF4D4F')
                .fontColor(Color.White)
                .fontSize(14)
                .margin({ top: 8, bottom: 16 })
                .onClick(() => {
                  this.logout();
                })
            } else {
              Button('去登录')
                .width('90%')
                .height(40)
                .borderRadius(20)
                .backgroundColor('#4E86FF')
                .fontColor(Color.White)
                .fontSize(14)
                .margin({ top: 16, bottom: 16 })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/LoginPage'
                  });
                })
            }
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16, bottom: 24 })
          .shadow({ radius: 8, color: '#0000001A', offsetX: 0, offsetY: 2 })
          
          // 功能菜单列表
          List() {
            ForEach(this.menuItems, (item: MenuItem) => {
              ListItem() {
                Row() {
                  // 图标
                  Text(item.icon)
                    .fontSize(24)
                    .margin({ right: 16 })
                  
                  // 标题
                  Text(item.title)
                    .fontSize(16)
                    .layoutWeight(1)
                  
                  // 箭头
                  Text('>')
                    .fontSize(16)
                    .fontColor('#CCCCCC')
                }
                .width('100%')
                .height(56)
                .padding({ left: 24, right: 24 })
                .onClick(() => {                  if (this.isLoggedIn || item.title === '系统设置') {
                    if (item.title === '我的评论' || item.title === '我的点赞' || item.title === '我的收藏' || item.title === '浏览历史') {
                      // 传递当前用户ID
                      router.pushUrl({
                        url: item.route,
                        params: {
                          userId: this.currentUserId
                        }
                      });
                    } else {
                      router.pushUrl({
                        url: item.route
                      });
                    }
                  } else {
                    promptAction.showToast({
                      message: '请先登录'
                    });
                  }
                })
              }
            })
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .divider({ strokeWidth: 1, color: '#F5F5F5' })
          .shadow({ radius: 8, color: '#0000001A', offsetX: 0, offsetY: 2 })
          
          // 版本信息
          Text('版本: 1.0.0')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 40, bottom: 20 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1) // 占用剩余空间
      .scrollBar(BarState.Off)
      
      // 添加底部导航栏
      CommonTabBar({ currentIndex: 2 }) // 1代表个人中心
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}