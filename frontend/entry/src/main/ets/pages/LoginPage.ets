import router from '@ohos.router';
import { UserService } from '../common/utils/UserService';
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
struct LoginPage {
  @State userId: string = '';
  @State password: string = '';
  @State errorMsg: string = '';
  @State isLoading: boolean = false;
  
  private userService: UserService = UserService.getInstance();
  private httpRequest = http.createHttp();

  build() {
    Column() {
      // 添加Logo和应用名称
      Column() {
        Image($r('app.media.logo'))
          .width(120)
          .height(120)
          .margin({ top: 50, bottom: 10 })
        
        Text('MuseLink-怀瑜')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 40 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 输入表单区域
      Column() {
        // 用户ID输入框
        TextInput({ placeholder: '请输入用户ID' })
          .type(InputType.Number)  // 改为数字输入类型
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .caretColor('#007DFF')
          .width('90%')
          .height(50)
          .margin({ bottom: 20 })
          .onChange((value: string) => {
            this.userId = value;
            this.errorMsg = '';
          })
        
        // 密码输入框
        TextInput({ placeholder: '请输入密码' })
          .type(InputType.Password)
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .caretColor('#007DFF')
          .width('90%')
          .height(50)
          .margin({ bottom: 20 })
          .onChange((value: string) => {
            this.password = value;
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
        
        // 登录按钮
        Button('登录', { type: ButtonType.Capsule })
          .width('90%')
          .height(50)
          .backgroundColor('#4E86FF')
          .margin({ top: 20, bottom: 10 })
          .onClick(() => {
            this.login();
          })
        
        // 注册链接
        Row() {
          Text('还没有账号？')
            .fontSize(14)
            .fontColor('#666666')
          Text('立即注册')
            .fontSize(14)
            .fontColor('#007DFF')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/RegisterPage'
              });
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
    .padding({ left: 12, right: 12 })
  }
  
  private async login() {
    // 输入验证
    if (!this.userId) {
      this.errorMsg = '请输入用户ID';
      return;
    }
    
    if (!this.password) {
      this.errorMsg = '请输入密码';
      return;
    }
    
    // 验证用户ID是否为数字
    const userIdNum = parseInt(this.userId);
    if (isNaN(userIdNum)) {
      this.errorMsg = '用户ID必须是数字';
      return;
    }
    
    this.isLoading = true;
    
    try {
      const url = ApiConstants.getFullUrl(ApiConstants.API_LOGIN);
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            userId: userIdNum,  // 使用解析后的数字类型用户ID
            password: this.password
          })
        }
      );
      
      if (response.responseCode === 200) {
        // 使用明确的类型
        const responseText = response.result as string;
        const result: ApiResponse = JSON.parse(responseText);
        
        if (result.success) {
          // 登录成功
          console.info(`登录成功: ${JSON.stringify(result.data)}`);
          
          // 保存用户ID，添加空值检查
          if (result.data && result.data.userId) {
            await this.userService.setCurrentUserId(result.data.userId);
            
            // 跳转到首页
            router.replaceUrl({
              url: 'pages/MainPage'
            });
          } else {
            this.errorMsg = '登录数据异常';
            console.error('登录成功但无用户数据');
          }
        } else {
          // 登录失败
          this.errorMsg = result.message || '登录失败';
          console.error(`登录失败: ${result.message}`);
        }
      } else {
        // HTTP请求失败
        this.errorMsg = '网络请求失败，请稍后重试';
        console.error(`HTTP请求失败: ${response.responseCode}`);
      }
    } catch (error) {
      // 移除类型注释
      this.errorMsg = '登录失败，请检查网络连接';
      console.error(`登录异常: ${JSON.stringify(error)}`);
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