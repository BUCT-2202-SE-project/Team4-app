import router from '@ohos.router';
import { TabItem } from '../../mode/type';
@Component
export struct CommonTabBar {
  @Prop currentIndex: number;

  // 导航项定义 - 简化为首页和个人中心两个按钮
  private tabItems: TabItem[] = [
    {
      icon: '🏛️',
      iconSelected: '🏛️',
      text: '首页',
      route: 'pages/MainPage'
    },
    {
      icon: '🏛️',
      iconSelected: '🏛️',
      text: '文物列表',
      route: 'pages/ArtifactListPage'
    },
    {
      icon: '👤',
      iconSelected: '👤',
      text: '个人中心',
      route: 'pages/ProfilePage'
    }
  ];

  build() {
    Column() {
      Row() {
        ForEach(this.tabItems, (item: TabItem, index: number) => {
          Column() {
            Text(this.currentIndex === index ? item.iconSelected : item.icon)  // 根据选中状态切换图标
              .fontColor(this.currentIndex === index ? '#4E86FF' : '#999999')
              .fontSize(22)
            Text(item.text)
              .fontColor(this.currentIndex === index ? '#4E86FF' : '#999999')
              .fontSize(12)
              .margin({ top: 4 })
          }
          .width('33.3%')  // 每个按钮占用33.3%的宽度
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.currentIndex === index) {
              return;  // 避免重复导航到当前页面
            }

            console.info(`准备跳转到: ${item.route}`);

            router.replaceUrl({
              url: item.route,
              params: {}  // 添加空参数对象
            }, (err) => {
              if (err) {
                console.error(`导航到${item.text}失败: ${JSON.stringify(err)}`);
              } else {
                console.info(`成功导航到${item.text}`);
              }
            });
          })
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height(60)
    .border({ width: { top: 1 }, color: '#EEEEEE' })
  }
}