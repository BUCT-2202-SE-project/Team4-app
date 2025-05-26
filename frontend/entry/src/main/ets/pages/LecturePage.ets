import router from '@ohos.router';
import CommonConstants from '../common/constants/CommonConstants';
@Entry
@Component
export default struct LecturePage {
  @State isExpanded: boolean = false;
  @StorageProp('currentDeviceSize') currentDeviceSize: string = CommonConstants.SM;
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
          Text('公益讲解')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 8, right: 16 })
            .alignSelf(ItemAlign.Center)
          Blank()
        }
        Scroll() {
          Column({space:4}) {
            Image($r('app.media.ic_lecture'))
              .width("100%")
              .height("200")
              .borderRadius(12)
            Column() {
              Row() {
                // 文本部分
                Text('公益讲解文物的具体形式和内容\n' +
                  '公益讲解文物介绍可以通过多种形式进行，包括:\n' +
                  '·现场讲解:在博物馆或历史遗址现场，由专业讲解员或志愿者向游客详细介绍文物的历史背景、制作工艺和文化价值。\n' +
                  '·线上直播:通过互联网平台进行直播讲解使无法到现场的观众也能参与到文化学习中\n' +
                  '·互动体验:组织互动活动，如文物修复体验、历史文化工作坊等，让公众亲身体验文物的魅力。\n'+
                  '公益讲解文物介绍的意义和影响\n' +
                  '公益讲解文物介绍的意义在于:\n' +
                  '·普及历史文化知识:通过生动的讲解和互动，让公众了解文物的历史背景和文化价值增强对文化遗产的保护意识。\n' +
                  '·促进文化传承:通过公益活动，传承和弘扬中华优秀传统文化，增强民族自豪感和文化自信。\n' +
                  '·社会教育功能:特别是对于青少年，通过参与公益讲解活动，可以激发他们对历史文化的兴趣，培养他们的爱国情怀和文化素养。')
                  .fontSize(16)
                  .maxLines(this.isExpanded ? undefined : 3) // 控制最大行数，使用 maxLines


                // 图标部分
                Image(this.isExpanded ? $r('app.media.ic_up') : $r('app.media.ic_down'))
                  .width(24)
                  .height(24)
                  .onClick(() => {
                    this.isExpanded = !this.isExpanded;
                  });
              }
              .margin({ left: 16, right: 16, top: 16 })
            }
            Column() {
              Row() {
                Text('公益讲解时间表')
                  .fontSize('16fp')
                  .fontWeight(FontWeight.Medium)
                  .alignSelf(ItemAlign.Start)
                  .margin('10vp')
              }
              Image($r('app.media.ic_time_table'))
                .width("100%")
                  // .height("100%")
                .borderRadius(12)
                .objectFit(ImageFit.Cover)
            }
          }
        }
        .height('80%')
      }
      .backgroundColor('#fff')
    }
  }
}