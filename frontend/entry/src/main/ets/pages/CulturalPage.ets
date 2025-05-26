import router from '@ohos.router';
import SwiperView2 from '../common/constants/SwiperView2';
@Entry
@Component
export default struct CulturalPage {
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
            .offset({ x: -100, y: 0 })
            .onClick(() => {
              router.back();
            })
          Text('餐饮服务')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 8, right: 16 })
            .alignSelf(ItemAlign.Center)
          Blank()
        }

        // 正文内容
        Scroll() {
          Column({space:2}) {
            SwiperView2()
            Column() {
              Row() {
                // 文本部分
                Text('在文化与旅游融合发展的大背景下，为加强中国国家博物馆的延伸文化服务，更好地落实习近平总书记关于“让文物活起来”的重要指示和中央关于鼓励文化文物单位文创产品开发的要求，国家博物馆文创团队励精图治，依托国博馆藏资源，大力开发文创产品，创新发展模式，拓展营销渠道。截止目前，我馆自主开发文创产品近5000款，涵盖了创意家居、办公用品、文具、服装配饰、邮品、玩具、电子产品、商务礼品等十二个大类，可满足不同消费层次人群的需求。\n' +
                  '国家博物馆授权国博(北京)文化产业发展有限公司全权开拓文创版块的业务。\n' +
                  '国博(北京)文化产业发展有限公司于2016年1月开始进行博物馆“馆藏IP+互联网”的深度融合探索。2016年1月28日，以“中国国家博物馆旗舰店”入驻 “天猫商城”为起点，国家博物馆与众多优质的社会力量开展合作，一方面深挖博物馆IP资源和文创产品设计开发的潜力，畅通从文物IP到原创设计、投资生产、线上销售的全产业渠道，形成文化资源与产业资源的无缝对接;另一方面，利用国博特有的馆藏文物资源、学术支撑与众多行业头部品牌进行授权合作，为品牌赋能，在增强品牌文化附加值的同时，为古老的文化遗产走进大众生活提供了新的思路。产品开发与品牌授权，双头并举，开拓了博物馆文创产业合作发展的新模式。')
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
              // 标题 + 查看更多
              Row({ space: 8 }) {
                Text('精选文创')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)

                Blank()

                Text('查看更多')
                  .fontSize(16)
                  .fontColor('#555555')
                  .onClick(() => {
                    // 示例跳转
                    // router.pushUrl({ url: 'FoodCreativityDetailPage' });
                  })
              }
              .margin({ left: 16, right: 16, top: 16 })

              // 商品网格布局
              Grid() {
                GridItem() {
                  Column() {
                    Image($r('app.media.ic_cultural1'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('花鸟玲珑香囊套装')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }

                GridItem() {
                  Column() {
                    Image($r('app.media.ic_cultural2'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('杏林春燕系列首饰')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }

                GridItem() {
                  Column() {
                    Image($r('app.media.ic_cultural3'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('星空音乐水晶球')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }

                GridItem() {
                  Column() {
                    Image($r('app.media.ic_cultural4'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('长乐未央红手绳')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }

                GridItem() {
                  Column() {
                    Image($r('app.media.ic_cultural5'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('缠枝纹咖啡杯')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }

                GridItem() {
                  Column() {
                    Image($r('app.media.ic_cultural6'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('溪山雨意书本灯')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }
              }
              .columnsTemplate('repeat(2, 1fr)')
              .rowsGap(16)
              .columnsGap(16)
              .margin({ left: 16, right: 16, top: 8 })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .height('80%')
      }
      .backgroundColor('#fff')
    }
  }
}
