import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
@Entry
@Component
export default struct FeedbackPage {
  @State feedback: string = ''
  @State desc: string = ''

  build() {
    Stack() {
      Column() {
        // 顶部返回和标题
        Row() {
          // 返回按钮
          Image($r('app.media.ic_back'))
            .width(32)
            .height(32)
            .offset({ x: -100, y: 0 })
            .onClick(() => {
              router.back();
            });
          Text('意见反馈')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 8, right: 16 })
            .alignSelf(ItemAlign.Center);
          Blank();
        }

        // 正文内容
        Scroll() {
          Column() {
            Text('问题/意见反馈').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 0, left: 16, right: 16 });
            Row() {
              TextArea({ placeholder:'请详细描述您在APP使用过程中遇到的问题，以便我们更好的为您服务。（400字以内）'})
                .onChange((val: string) => this.feedback = val )
                .border({ width: 1, color: '#e0e0e0' })
                .borderRadius(20)
                .maxLength(400)
                .height('300vp')
                .width("100%")
            }
            Button('提交')
              .type(ButtonType.Normal)
              .margin({ top: 16, left: 16, right: 16 })
              .onClick(() => {
                // 显示提交成功提示
                promptAction.showToast({
                  message: '提交成功',
                  duration: 400
                });
              })
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Center)
        }
        .height('80%');
      }
      .backgroundColor('#fff');
    };
  }
}
