import router from '@ohos.router';
import SwiperView1 from '../common/constants/SwiperView1';
@Entry
@Component
export default struct CateringPage {
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
            SwiperView1()
            Column() {
              Row() {
                // 文本部分
                Text('国博(北京)饮食文化有限公司作为中国国家博物馆的馆属企业，本着服务至上的理念，在中国国家博物馆内设立了三个食品销售区，一个咖啡厅，并于馆内各层设置了十余台自动饮料、食品售卖机，为观众提供矿泉水、饮料等十多种冷热饮品及三明治、自加热盒饭等多种简餐服务，以满足观众的不同需求。力图使每一位来到博物馆参观的观众不仅能徜徉在丰富多彩的展览中，同时也能享受到博物馆内的各种贴心服务，提高观众参观体验的满意度，进而提高中国国家博物馆的美誉度。\n' +
                  '随着国家对文创产业的大力支持，我集团在保证观众饮食服务刚需的同时，不断追求创新，自主研发与IP授权业务相结合，积极响应“让文物活起来”的号召，围绕国博的展览业务，深入研究，提前介入，以产品为载体，以国博文物为元素，选取有代表性的器物、图案进行特色文创食品的开发，将中国文化、国博元素与美食相结合，大力弘扬传播中国优秀文化，打造具有国博自身特色的明星产品。使观众在参观之余，还能品尝到独具国博特色的文化饮食，在服务观众的同时更好的推动文创产业发展。')
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
                Text('食品文创')
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
                    Image($r('app.media.ic_food1'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('国博棒棒糖')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }
                GridItem() {
                  Column() {
                    Image($r('app.media.ic_food2'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('如意茶饼')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }
                GridItem() {
                  Column() {
                    Image($r('app.media.ic_food3'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('文物雪糕')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }
                GridItem() {
                  Column() {
                    Image($r('app.media.ic_food4'))
                      .width('100%')
                      .height('150vp')
                      .borderRadius(8)
                    Text('心有灵犀咖啡杯')
                      .fontSize(16)
                      .margin({ top: 8 })
                  }
                }
              }
              .columnsTemplate('repeat(2, 1fr)')
              .rowsGap(16)
              .columnsGap(16)
              .margin({ left: 16, right: 16, top: 8 })
              Column() {
                // 标题
                Row({ space: 8 }) {
                  Text('食品销售区')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)

                  Blank()
                }
                .margin({ left: 16, right: 16, top: 16 })

                // 销售区列表
                Grid() {
                  GridItem() {
                    Column() {
                      Image($r('app.media.ic_catering1'))
                        .width('100%')
                        .height('150vp')
                        .borderRadius(8)
                      Text('三楼北饮食空间')
                        .fontSize(16)
                        .margin({ top: 8 })
                    }
                  }
                  GridItem() {
                    Column() {
                      Image($r('app.media.ic_catering2'))
                        .width('100%')
                        .height('150vp')
                        .borderRadius(8)
                      Text('三楼南饮食空间')
                        .fontSize(16)
                        .margin({ top: 8 })
                    }
                  }
                  GridItem() {
                    Column() {
                      Image($r('app.media.ic_catering3'))
                        .width('100%')
                        .height('150vp')
                        .borderRadius(8)
                      Text('四楼咖啡厅')
                        .fontSize(16)
                        .margin({ top: 8 })
                    }
                  }
                  GridItem() {
                    Column() {
                      Image($r('app.media.ic_catering4'))
                        .width('100%')
                        .height('150vp')
                        .borderRadius(8)
                      Text('四楼剧院餐厅')
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
            }
            // Column End
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
