import router from '@ohos.router';
@Entry
@Component
export default struct MessagePage {
  build() {
    Stack() {
      Column() {
        // 顶部返回和标题
        Row() {
          // 返回按钮
          Image($r('app.media.ic_back'))
            .width(32)
            .height(32)
            .offset({x:-100,y:0})
            .onClick(() => {
              router.back();
            })
          Text('消息通知')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 8, right: 16 })
            .alignSelf(ItemAlign.Center)
          Blank()
        }

        Scroll() {
          Column() {

          }
        }
        .height('80%')
      }
      .backgroundColor('#fff')
    }
  }
}