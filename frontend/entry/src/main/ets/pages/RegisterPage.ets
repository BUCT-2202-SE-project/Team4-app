import router from '@ohos.router';
import ApiConstants from '../common/constants/ApiConstants';
import http from '@ohos.net.http';

// 添加用户数据接口
interface UserData {
  userId: number;
  username: string;
  email?: string;
  registerTime?: string;
  permissionStatus?: string;
}

// 添加API响应接口
interface ApiResponse {
  success: boolean;
  message: string;
  data?: UserData;
}

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State email: string = '';
  @State errorMsg: string = '';
  @State isLoading: boolean = false;
  
  private httpRequest = http.createHttp();

  build() {
    Column() {

      // 标题区域
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        Text('注册账号')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16, top: 16, bottom: 16 })
      
      // 输入表单区域
      Column() {
        // 用户名输入框
        TextInput({ placeholder: '请输入用户名(3-20个字符)' })
          .type(InputType.Normal)
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .caretColor('#007DFF')
          .width('90%')
          .height(50)
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.username = value;
            this.errorMsg = '';
          })
        
        // 密码输入框
        TextInput({ placeholder: '请输入密码(6-20个字符)' })
          .type(InputType.Password)
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .caretColor('#007DFF')
          .width('90%')
          .height(50)
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.password = value;
            this.errorMsg = '';
          })
          
        // 确认密码输入框
        TextInput({ placeholder: '请确认密码' })
          .type(InputType.Password)
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .caretColor('#007DFF')
          .width('90%')
          .height(50)
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.confirmPassword = value;
            this.errorMsg = '';
          })
          
        // 邮箱输入框
        TextInput({ placeholder: '请输入邮箱' })
          .type(InputType.Email)
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .caretColor('#007DFF')
          .width('90%')
          .height(50)
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.email = value;
            this.errorMsg = '';
          })
        
        // 错误提示
        if (this.errorMsg.length > 0) {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor(Color.Red)
            .width('90%')
            .margin({ bottom: 10 })
        }
        
        // 注册按钮
        Button('注册', { type: ButtonType.Capsule })
          .width('90%')
          .height(50)
          .backgroundColor('#4E86FF')
          .margin({ top: 20, bottom: 10 })
          .onClick(() => {
            this.register();
          })
        
        // 登录链接
        Row() {
          Text('已有账号？')
            .fontSize(14)
            .fontColor('#666666')
          Text('去登录')
            .fontSize(14)
            .fontColor('#007DFF')
            .onClick(() => {
              router.back();
            })
        }
        .width('90%')
        .margin({ top: 15 })
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  private validateForm(): boolean {
    // 验证用户名
    if (!this.username || this.username.length < 3 || this.username.length > 20) {
      this.errorMsg = '用户名长度应为3-20个字符';
      return false;
    }
    
    // 验证密码
    if (!this.password || this.password.length < 6 || this.password.length > 20) {
      this.errorMsg = '密码长度应为6-20个字符';
      return false;
    }
    
    // 验证确认密码
    if (this.password !== this.confirmPassword) {
      this.errorMsg = '两次输入的密码不一致';
      return false;
    }
    
    // 验证邮箱
    const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
    if (!this.email || !emailRegex.test(this.email)) {
      this.errorMsg = '请输入有效的邮箱地址';
      return false;
    }
    
    return true;
  }
  
  private async register() {
    // 表单验证
    if (!this.validateForm()) {
      return;
    }
    
    this.isLoading = true;
    
    try {
      const url = ApiConstants.getFullUrl(ApiConstants.API_REGISTER);
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            username: this.username,
            password: this.password,
            email: this.email
          })
        }
      );
      
      if (response.responseCode === 200) {
        // 使用明确的类型
        const responseText = response.result as string;
        const result: ApiResponse = JSON.parse(responseText);
        
        if (result.success) {
          // 注册成功
          console.info(`注册成功: ${JSON.stringify(result.data)}`);
          
          // 显示成功提示并返回登录页
          AlertDialog.show(
            {
              title: '注册成功',
              message: '账号注册成功，请返回登录页面',
              confirm: {
                value: '确定',
                action: () => {
                  router.back();
                }
              }
            }
          );
        } else {
          // 注册失败
          this.errorMsg = result.message || '注册失败';
          console.error(`注册失败: ${result.message}`);
        }
      } else {
        // HTTP请求失败
        this.errorMsg = '网络请求失败，请稍后重试';
        console.error(`HTTP请求失败: ${response.responseCode}`);
      }
    } catch (error) {
      // 移除类型注释
      this.errorMsg = '注册失败，请检查网络连接';
      console.error(`注册异常: ${JSON.stringify(error)}`);
    } finally {
      this.httpRequest.destroy();
      this.isLoading = false;
    }
  }
  
  aboutToDisappear() {
    // 销毁HTTP请求对象，避免内存泄漏
    this.httpRequest.destroy();
  }
}