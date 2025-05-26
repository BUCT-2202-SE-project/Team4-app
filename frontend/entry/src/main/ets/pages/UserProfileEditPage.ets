import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import http from '@ohos.net.http';
import ApiConstants from '../common/constants/ApiConstants';
import { UserService } from '../common/utils/UserService';

// 定义HTTP错误类型
interface HttpError {
  code?: number;
  message?: string;
}

// 定义用户类型
interface User {
  userId: number;
  username: string;
  email: string;
  registerTime: string;
}

// API响应接口
interface ApiResponse {
  success: boolean;
  message?: string;
  data?: User;
}

// 路由参数接口
interface RouteParams {
  userId?: number;
  // 移除索引签名，改为具体的可选属性
  url?: string;
  uri?: string;
  // 其他可能的参数，根据需要添加...
}

@Entry
@Component
struct UserProfileEditPage {
  @State user: User = { userId: 0, username: '', email: '', registerTime: '' };
  @State username: string = '';
  @State email: string = '';
  @State isLoading: boolean = true;
  @State isSaving: boolean = false;
  @State errorMsg: string = '';
  @State deleteConfirmText: string = '';
  @State isDeleting: boolean = false;
  @State showDeleteConfirm: boolean = false;
  
  private httpRequest = http.createHttp();
  private userService: UserService = UserService.getInstance();
  private currentUserId: number = 0;
    aboutToAppear() {
    // 从用户服务获取当前用户ID
    this.currentUserId = this.userService.getCurrentUserId();
    
    // 获取路由参数
    const params = router.getParams() as RouteParams;
    if (params && params.userId !== undefined) {
      this.currentUserId = params.userId;
    }
    
    // 获取用户信息
    this.loadUserInfo();
  }
  
  aboutToDisappear() {
    this.httpRequest.destroy();
  }
  
  // 加载用户信息
  loadUserInfo() {
    this.isLoading = true;
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
              const result: ApiResponse = JSON.parse(resultStr);
              
              if (result.success && result.data) {
                this.user = result.data;
                this.username = this.user.username;
                this.email = this.user.email;
                console.info(`获取用户信息成功: 用户ID=${this.user.userId}`);
              } else {
                this.errorMsg = result.message || '获取用户信息失败';
                console.error('获取用户信息失败: ' + this.errorMsg);
              }
            } catch (e) {
              this.errorMsg = `解析用户信息异常: ${e.toString()}`;
              console.error(this.errorMsg);
            }
          } else {
            this.errorMsg = err ? `请求失败: ${err.message}` : '网络请求异常';
            console.error(`获取用户信息请求失败: ${this.errorMsg}`);
          }
          this.isLoading = false;
        }
      );
    } catch (e) {
      this.errorMsg = `发起请求异常: ${e.toString()}`;
      console.error(this.errorMsg);
      this.isLoading = false;
    }
  }
  
  // 保存用户信息
  saveUserInfo() {
    // 表单验证
    if (!this.username || this.username.trim() === '') {
      promptAction.showToast({ message: '用户名不能为空' });
      return;
    }
    
    if (!this.email || this.email.trim() === '') {
      promptAction.showToast({ message: '邮箱不能为空' });
      return;
    }
    
    // 邮箱格式验证
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.email)) {
      promptAction.showToast({ message: '邮箱格式不正确' });
      return;
    }
    
    // 自动移除用户名中的空格
    const trimmedUsername = this.username.replace(/\s+/g, '');
    if (trimmedUsername !== this.username) {
      this.username = trimmedUsername;
      console.info('用户名中的空格已被自动移除');
    }
    
    this.isSaving = true;
    const url = ApiConstants.getFullUrl(ApiConstants.API_USER_UPDATE);
    
    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.PUT,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            userId: this.currentUserId,
            username: this.username,
            email: this.email
          }),
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          this.isSaving = false;
          
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '{}';
              const result: ApiResponse = JSON.parse(resultStr);
              
              if (result.success) {
                promptAction.showToast({ message: '保存成功' });
                // 返回上一页
                setTimeout(() => {
                  router.back();
                }, 1000);
              } else {
                promptAction.showToast({ message: result.message || '保存失败' });
              }
            } catch (e) {
              console.error(`解析保存响应异常: ${e.toString()}`);
              promptAction.showToast({ message: '保存失败，请重试' });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            console.error(`保存请求失败: ${errMsg}`);
            promptAction.showToast({ message: `保存失败: ${errMsg}` });
          }
        }
      );
    } catch (e) {
      this.isSaving = false;
      console.error(`发起保存请求异常: ${e.toString()}`);
      promptAction.showToast({ message: '保存失败，请检查网络连接' });
    }
  }
  
  // 注销账号
  deleteAccount() {
    if (this.deleteConfirmText !== 'DELETE') {
      promptAction.showToast({ message: '请输入DELETE确认注销' });
      return;
    }
    
    this.isDeleting = true;
    const url = ApiConstants.getFullUrl(`${ApiConstants.API_USER_DELETE}/${this.currentUserId}`);
    
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
                promptAction.showToast({ message: '账号已注销' });
                
                // 重置用户状态并跳转到登录页
                this.userService.resetUserId();
                
                setTimeout(() => {
                  router.replaceUrl({
                    url: 'pages/LoginPage'
                  });
                }, 1000);
              } else {
                promptAction.showToast({ message: result.message || '注销失败' });
              }
            } catch (e) {
              console.error(`解析注销响应异常: ${e.toString()}`);
              promptAction.showToast({ message: '注销失败，请重试' });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            console.error(`注销请求失败: ${errMsg}`);
            promptAction.showToast({ message: `注销失败: ${errMsg}` });
          }
        }
      );
    } catch (e) {
      this.isDeleting = false;
      console.error(`发起注销请求异常: ${e.toString()}`);
      promptAction.showToast({ message: '注销失败，请检查网络连接' });
    }
  }
  
  build() {
    Column() {
      // 顶部标题栏
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
        Text('编辑个人资料')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          
        // 保存按钮
        Button({ type: ButtonType.Normal }) {
          Text('保存')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4E86FF')
        }
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => {
          this.saveUserInfo();
        })
        .enabled(!this.isSaving)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 主内容区域
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
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMsg) {
        // 错误信息显示
        Column() {
          Text('加载失败')
            .fontSize(18)
            .fontColor('#FF4D4F')
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
          Button('重试')
            .margin({ top: 16 })
            .onClick(() => {
              this.errorMsg = '';
              this.loadUserInfo();
            })
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 表单内容
        Scroll() {
          Column() {
            // 个人信息编辑区域
            Column() {
              // 用户ID（只读）
              Column() {
                Text('用户ID')
                  .fontSize(14)
                  .fontColor('#999999')
                  .alignSelf(ItemAlign.Start)
                Text(this.user.userId.toString())
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .height(48)
                  .margin({ top: 4 })
                  .padding({ left: 16, right: 16 })
                  .borderRadius(8)
                  .backgroundColor('#F5F5F5')
                  .alignSelf(ItemAlign.Start)
              }
              .width('100%')
              .margin({ top: 16 })
              
              // 用户名
              Column() {
                Text('用户名')
                  .fontSize(14)
                  .fontColor('#999999')
                  .alignSelf(ItemAlign.Start)
                TextInput({ 
                  text: this.username,
                  placeholder: '请输入用户名' 
                })
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .margin({ top: 4 })
                  .padding({ left: 16, right: 16 })
                  .borderRadius(8)
                  .backgroundColor('#F5F5F5')
                  .onChange((value: string) => {
                    this.username = value;
                  })
              }
              .width('100%')
              .margin({ top: 16 })
              
              // 邮箱
              Column() {
                Text('邮箱')
                  .fontSize(14)
                  .fontColor('#999999')
                  .alignSelf(ItemAlign.Start)
                TextInput({
                  text: this.email,
                  placeholder: '请输入邮箱'
                })
                  .type(InputType.Email)
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .margin({ top: 4 })
                  .padding({ left: 16, right: 16 })
                  .borderRadius(8)
                  .backgroundColor('#F5F5F5')
                  .onChange((value: string) => {
                    this.email = value;
                  })
              }
              .width('100%')
              .margin({ top: 16 })
              
              // 注册时间（只读）
              Column() {
                Text('注册时间')
                  .fontSize(14)
                  .fontColor('#999999')
                  .alignSelf(ItemAlign.Start)
                Text(this.user.registerTime || '未知')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .height(48)
                  .margin({ top: 4 })
                  .padding({ left: 16, right: 16 })
                  .borderRadius(8)
                  .backgroundColor('#F5F5F5')
                  .alignSelf(ItemAlign.Start)
              }
              .width('100%')
              .margin({ top: 16 })
            }
            .width('90%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 16 })
            
            // 注销账号区域
            Column() {
              Text('注销账号')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF4D4F')
                .alignSelf(ItemAlign.Start)
                
              Text('注意：账号注销后，所有数据将无法恢复，请谨慎操作。')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 8, bottom: 16 })
                .alignSelf(ItemAlign.Start)
                
              if (this.showDeleteConfirm) {
                // 注销确认输入框
                TextInput({ 
                  placeholder: '请输入DELETE确认注销',
                  text: this.deleteConfirmText
                })
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .margin({ bottom: 16 })
                  .padding({ left: 16, right: 16 })
                  .borderRadius(8)
                  .backgroundColor('#FFF1F0')
                  .borderWidth(1)
                  .borderColor('#FF4D4F')
                  .onChange((value: string) => {
                    this.deleteConfirmText = value;
                  })
                  
                Row() {
                  // 取消按钮
                  Button('取消')
                    .fontSize(16)
                    .height(40)
                    .width('45%')
                    .backgroundColor('#F5F5F5')
                    .fontColor('#666666')
                    .onClick(() => {
                      this.showDeleteConfirm = false;
                      this.deleteConfirmText = '';
                    })
                    
                  // 确认注销按钮
                  Button({ 
                    type: ButtonType.Normal,
                    stateEffect: true
                  }) {
                    Row() {
                      Text('确认注销')
                        .fontSize(16)
                        .fontColor('#FFFFFF')
                      if (this.isDeleting) {
                        LoadingProgress()
                          .width(16)
                          .height(16)
                          .color('#FFFFFF')
                          .margin({ left: 4 })
                      }
                    }
                  }
                  .height(40)
                  .width('45%')
                  .backgroundColor('#FF4D4F')
                  .onClick(() => {
                    this.deleteAccount();
                  })
                  .enabled(!this.isDeleting)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              } else {
                Button('注销账号')
                  .fontSize(16)
                  .height(40)
                  .width('100%')
                  .backgroundColor('#FFF1F0')
                  .fontColor('#FF4D4F')
                  .onClick(() => {
                    this.showDeleteConfirm = true;
                  })
              }
            }
            .width('90%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 24, bottom: 40 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
