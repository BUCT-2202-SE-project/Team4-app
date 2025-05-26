import router from '@ohos.router';

@Entry
@Component
export default struct ServicePage {
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
          Text('便民服务')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 8, right: 16 })
            .alignSelf(ItemAlign.Center);
          Blank();
        }
        Scroll() {
          Column() {
            // 咨询服务
            Row() {
              Text('咨询服务').fontSize(18).fontColor('#b22222').margin({ top: 16, bottom: 8, left: 16 });
              Text('查看位置').fontSize(14).fontColor('#555555').margin({ top: 16, bottom: 8, right: 16 }).alignSelf(ItemAlign.End);
            }
            Text('博物馆服务台（位置：北门入口处）').fontSize(16).margin({ left: 16, right: 16, bottom: 16 });

            Divider().margin({ left: 16, right: 16, bottom: 16 });

            // 轮椅、婴儿车
            Row() {
              Text('轮椅、婴儿车').fontSize(18).fontColor('#b22222').margin({ top: 16, bottom: 8, left: 16 });
            }
            Text('当日免费使用，需提供有效证件及押金500元，在服务台即可办理手续。').fontSize(16).margin({ left: 16, right: 16, bottom: 16 });

            Divider().margin({ left: 16, right: 16, bottom: 16 });

            // 母婴室
            Row() {
              Text('母婴室').fontSize(18).fontColor('#b22222').margin({ top: 16, bottom: 8, left: 16 });
            }
            Text('母婴室位于国家博物馆一层大厅南侧，为有需要的哺乳期妈妈提供安全、私密、温馨的哺乳、集乳及婴儿护理的空间。').fontSize(16).margin({ left: 16, right: 16, bottom: 16 });

            Divider().margin({ left: 16, right: 16, bottom: 16 });

            // 失物招领
            Row() {
              Text('失物招领').fontSize(18).fontColor('#b22222').margin({ top: 16, bottom: 8, left: 16 });
              Text('查看失物列表').fontSize(14).fontColor('#555555').margin({ top: 16, bottom: 8, right: 16 }).alignSelf(ItemAlign.End);
            }
            Text('如果您在展厅内丢失物品，请您及时到服务台进行登记；如果您已经离开，并且确定是在我馆丢失，请您拨打咨询热线010-65116400咨询相关信息。').fontSize(16).margin({ left: 16, right: 16, bottom: 16 });

            Divider().margin({ left: 16, right: 16, bottom: 16 });

            // 留言簿
            Row() {
              Text('留言簿').fontSize(18).fontColor('#b22222').margin({ top: 16, bottom: 8, left: 16 });
            }
            Text('常设展览设有留言簿，欢迎观众踊跃留言！').fontSize(16).margin({ left: 16, right: 16, bottom: 16 });

            Divider().margin({ left: 16, right: 16, bottom: 16 });

            // 应急处置
            Row() {
              Text('应急处置').fontSize(18).fontColor('#b22222').margin({ top: 16, bottom: 8, left: 16 });
            }
            Text('如果您在参观过程中突感身体不适或意外受伤，请及时与工作人员联系。如果您在参观过程中与亲友走散，请前往服务台，工作人员将为您提供广播寻人服务。如遇突发情况，请您服从现场工作人员指挥，按照疏散标识快速有序的撤离至安全区域。').fontSize(16).margin({ left: 16, right: 16, bottom: 16 });

            Divider().margin({ left: 16, right: 16, bottom: 16 });

            // 意见投诉
            Row() {
              Text('意见投诉').fontSize(18).fontColor('#b22222').margin({ top: 16, bottom: 8, left: 16 });
              Text('在线反馈').fontSize(14).fontColor('#555555').margin({ top: 16, bottom: 8, right: 0 }).alignSelf(ItemAlign.End)
                .onClick(() => {
                  router.pushUrl({ url: 'pages/FeedbackPage' })
                })
            }
            Text('如果您对场馆、展览、服务等有意见，请到中国国家博物馆服务台进行投诉。').fontSize(16).margin({ left: 16, right: 16, bottom: 16 })
          }
        }
        .height('80%');
      }
      .backgroundColor('#fff');
    };
  }
}