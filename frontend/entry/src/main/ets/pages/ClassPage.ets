import router from '@ohos.router';
@Entry
@Component
export default struct ClassPage {
  @State isExpanded: boolean = false;
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
          Text('藏品好课')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 8, right: 16 })
            .alignSelf(ItemAlign.Center)
          Blank()
        }

        Scroll() {
          Column({space:2}) {
            Column() {
              Row() {
                // 文本部分
                Text('习近平总书记强调，学校。”好学校就应当既有好老师又有好课程。中国国家博物馆以传统品牌活动“国博讲堂”为基础，隆重推出《国博好课》，就是要通过文博大咖们的精彩讲述，对值得反复回味的展览和藏品进行再聚焦再阐释，把学术严谨性和课堂生动性融会贯通起来，进而作出拓展性的诠释。从这个意义来说，《国博好课》以重构观众与馆藏资源的认知纽带与体验模式为导向，将历史文化、时代背景与文物藏品融于一体，不仅有助于观众丰富历史文物知识，进一步开拓视野、提升鉴赏能力和水平，而能够引导观众通过云端课堂掌握历史文化学习的“自由裁量权”和时间利用的“灵活支配权”，切身体验博大深邃的历史空间、感悟魅力无穷的历史智慧，从而更进一步坚定文化自信，更好地传承弘扬中华优秀传统文化的精神标识。')
                  .fontSize(16)
                  .maxLines(this.isExpanded ? undefined : 4) // 控制最大行数，使用 maxLines


                // 图标部分
                Image(this.isExpanded ? $r('app.media.ic_up') : $r('app.media.ic_down'))
                  .width(24)
                  .height(24)
                  .onClick(() => {
                    this.isExpanded = !this.isExpanded;
                  });
              }
              .margin({ left: 16, right: 16, top: 0 })
            }


          }
        }
        .height('80%')
      }
      .backgroundColor('#fff')
    }
  }
}