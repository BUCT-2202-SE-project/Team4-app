import router from '@ohos.router';
@Entry
@Component
export default struct VistPage {
  @State selectedCategory: number = 0;
  private categories: string[] = ['文明参观须知', '观众存包须知', '请勿携带物品清单', '展品拍照须知'];
  // 进馆须知内容
  private entryRules: string[][] = [
    [// 文明参观须知
      `为营造安全、庄重、有序的良好环境，确保文物安全、观众安全、馆舍安全，特制定文明参观须知如下：
      一、入馆
        1.观众入馆须自觉接受安全检查，醉酒者、仪容不整者(包含穿着过于暴露、穿着拖鞋等)谢绝入馆;
        2.未满14周岁(含)的青少年须在成年人陪伴下馆;
        3.禁止携带入馆物品详见《中国国家博物馆禁限带物品清单》，电动代步工具禁止入馆;
      二、观展
        4.馆内禁止追逐打闹、大声喧哗、攀爬躺卧、随意丢弃杂物等不文明行为;
        5.禁止音响外放、长时间占用公共设施及公共空间等影响其他观众观展的行为;
        6.禁止翻越围挡护栏，触摸、污损、毁坏展品等行为;
        7.禁止在标有禁拍标识的区域拍照，未经允许禁止使用闪光灯、自拍杆和支架类摄影器材;
        8.展厅内请勿使用充电宝;
      三、活动
        9.禁止乞讨、卖艺、打小旗、拉横幅，禁止散发悬挂、粘贴广告以及其它违背公序良俗的活动或行为;
        10.未经批准，禁止进行讲学、表演、采访、商业性拍摄、自媒体直播、录播等非参观活动;
        11.展厅内和非餐饮区禁止饮食;
      四、安全
        12.馆舍内外全部区域禁止吸烟;
        13.严格遵守电梯、扶梯、楼梯使用安全规定，严禁在扶梯上坐卧、玩要、逆行、奔跑，以及推行轮椅、婴儿车等危险行为;
        14.禁止随意挪用、触动和损坏馆内消防设施、器材;
        15.如遇特殊活动或突发事件，须接受现场工作人员引导，有序疏散;
      五、责任
        16.违反本规定的，安全保卫人员有权责令停止，直至责令离馆;
        17.造成人身和财产损失的，依法追究行为人相应法律责任;
        18.未尽事宜以本馆公示为准;
        19.本须知自发布之日起施行。`
    ],
    [// 观众存包须知
      '本馆存包处是为我馆观众设立的临时寄存行李包裹的场所，非来馆参观的游客请勿使用;\n' +
        '观众携带的拉杆箱、行李箱及所有尺寸大于40厘米的包裹等物品须寄存，存包处提供有偿寄存服务;观众存包前请自觉接受安全检查，不得存放易燃，易爆及易腐蚀性化学物品和国家明令禁止的物品，未经过安全检查的物品不予寄存;\n' +
        '本存包处不予存放现金、首饰、易损易碎等贵重物啦;观众如存放电子产品、各类收藏品等特殊物品，需如实填写《物品存放登记表》并由本人签字后方可寄存，物品出现损坏等后果由寄存人自行承担;\n' +
        '观众应妥善保管好存包手牌，凭手牌取回所存物件。存包手牌如有丢失，应立即办理挂失手续(需缴纳存包手牌工本费20元)，因手牌遗失造成财产损失\n' +
        '责任由寄存人负担;\n' +
        '办理存取手续一律在存包处前台，禁止进入存包室大:所存物品请于当日17:00前取出，闭馆后不再办理取包手续;\n' +
        '当日未取物品，每超过8小时按照收费标准再计费\n' +
        '次;\n' +
        '留存物品出现变质、自然损坏等情况由物品所有人承担。(食物类物品在存放期间发生变质等情况，工作人员有权进行销毁处理)超过一周仍未取走的物品将视为丢弃，工作人员将进行销毁处理。',
    ],
    [// 请勿携带物品清单
      '1各类枪支(含主要零部件)装置、能够发射弹丸)、水枪等。\n' +
        '1.1军用枪、公务用枪:如手枪、步枪、冲锋枪、机\n' +
        '枪、防暴枪等。\n' +
        '1.2民用枪:如气枪、猎枪、射击运动枪、麻醉注射\n' +
        '枪等。\n' +
        '1.3其他枪支:如道具枪、发令枪、钢珠枪、砸炮\n' +
        '枪、境外枪支以及各类非法制造的枪支。\n' +
        '1.4本类别下物品的仿真品:如儿童玩具枪(有击发\n' +
        '2管制刀具、军警械具及具有一定杀伤力的其他器具\n' +
        '2.1管制刀具:如专用刀具(匕首、刺刀、三棱刮刀、猎刀、弹簧刀、带自锁装置折叠刀等)、厨用刀具(砍骨刀、西瓜刀、剔骨刀、屠宰刀、多用刀等)武术与工艺礼品刀具以及陶瓷类刀具。\n' +
        '2.2军械具:如棍、用电击器、军用或警用的匕首、手铐、拇指铐、脚镣、催泪喷射器。\n' +
        '2.3锐器、钝器:如菜刀、砍刀等刀具，锤、锥、铲、锹、镐、螺丝刀等工具。\n' +
        '2.4具有一定杀伤力的器具:如防卫器、弓、弩、射钉枪、弹弓等。\n' +
        '2.5其他属于国家规定的管制器具。\n' +
        '3各类弹药、易燃易爆物和装置\n' +
        '3.1弹药:如炸弹、手榴弹、照明弹、燃烧弹、烟幕弹、信号弹、催泪弹、毒气弹、子弹(铅弹、空包弹、教练弹)。\n' +
        '3.2爆破器材:如炸药、雷管、引信、起爆管、导火索、导爆索、爆破剂。\n' +
        '3.3烟火制品:如烟花爆竹、烟饼、礼花弹、摔炮、射钉弹、发令弹等。\n' +
        '3.4其他可能危害人身安全或公共安全的爆炸或燃烧装置(物质)或者可能被误认为是此类装置的物品。\n' +
        '3.5包装上带有易燃、易爆等危险化学品标志或提示信息的物品:如打火机、火柴、含酒精的饮品、喷雾(防晒喷雾)等。\n' +
        '3.6压缩气体和液化气体:如氢气、甲烷、乙烷、丁烷、天然气、乙烯、丙烯、乙炔(溶于介质的)、一氧化碳、液化石油气、氟利昂、氧气、二氧化碳、水煤气、打火机燃料及打火机用液化气体等。\n' +
        '3.7自燃物品:如黄磷、白磷及其制品等。\n' +
        '3.8易燃液体:如汽油、煤油、柴油、苯、乙醇(酒精)、丙酮、乙醚、油漆、稀料、松香油及含易燃溶剂制品等。\n' +
        '3.9易燃固体:如红磷、闪光粉、固体酒精、发泡剂。\n' +
        '3.10毒害品:如氰化物、砒霜、剧毒农药等剧毒化学品。\n' +
        '3.11腐蚀性物品:如硫酸、盐酸、氢氟酸、氢氧化钠、氢氧化钾、汞(水银)等。\n' +
        '3.12其他可能危害人身安全或公共安全的物品，如有强烈刺激性气味的物品，不能判明性质但可能具有危害性的物品等。\n' +
        '4其他物品\n' +
        '4.1各类文物及仿制品、字画等艺术品。\n' +
        '4.2露营装备:如帐篷、吊床、折叠桌、露营车等。\n' +
        '4.3体育用品:如足球、球、球拍、跳绳等。\n' +
        '4.4宣传品:如各类危害国家安全和社会政治稳定或影响参观秩序的出版物、印刷品、音像制品等。\n'+
        '4.5可能影响社会秩序或公共安全的升空类物品:如风筝、气球以及“低慢小”无人机、航拍器等。\n'+
        '4.6除老、幼、病、残、孕观众本人必要使用的代步轮椅、婴儿车以外的其他代步工具(含电动代步工具)，如电动轮椅(遥控椅)、滑板车、自动平衡车、自行车、轮滑等。我馆为使用电动代步工具来馆的残疾人、老年人提供替代性服务措施。\n' +
        '4.7所有具有运输装载功能的带轮工具，例如野餐车、营地车、手拖车、带座椅的行李箱、拖挂车等\n'+
        '4.8商用摄影、摄像器材:如滑轨、摇臂、落地式三脚架。\n' +
        '4.9所有动物(含残疾人携带的导盲犬、导听犬、辅助犬等服务犬)。我馆为残疾人携带的导盲犬、导听犬、辅助犬等服务犬提供便利安排。\n' +
        '4.10各种漆类:如油漆、自喷漆、墙漆涂料等，\n' +
        '4.11可能危害文物安全及扰乱参观秩序的物品:如晾衣杆、尖钉登山杆、逗猫杆、鱼竺、渔网、展开超1.3米的自拍杆、乐器及音响设备等。\n' +
        '4.12单一充电宝容量不超过20000毫安时(mAh)。根据《中华人民共和国产品质量法》:\n' +
        '《产品质量监督抽查管理暂行办法》，不能满足国家标准认证的;标识不清、破损、经过缠裹的充电宝以及超过标准容量或未标明容量的充电宝，不得携带入馆。请提前自行处理。\n' +
        '4.13自热类食品。\n' +
        '4.14国家法律、行政法规、规章规定的其他禁止持有、携带的物品。',
    ],
    [// 展品拍照须知
      '基于中国国家博物馆藏品举办的陈列展览，欢迎观众拍照留念，但请勿使用闪光灯、自拍杆和脚架。\n' +
        '拍照时请注意自身、他人及展品安全。\n' +
        '临时性展览，将依据办展协议确定是否可以拍照，若不可拍照，将在展厅门口及展厅内设立提示标识，请注意查看，或咨询展厅服务人员。\n' +
        '新闻记者若因工作需要，须进入展厅进行拍照，请参照《国家博物馆新闻采访办法》的相关规定办理手续。\n' +
        '感谢您的理解与支持!',
    ]
  ];
  MyScroll:Scroller=new Scroller()
  build() {
    Stack() {
      // 主体内容可滚动
      Column() {
        Row() {
          // 返回按钮
          Image($r('app.media.ic_back'))
            .width(32)
            .height(32)
            .offset({ x: -100, y: 0 })
            .onClick(() => {
              router.back();
            })
          Text('参观信息')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 8, right: 16 })
            .alignSelf(ItemAlign.Center)
          Blank()
        }

        Scroll() {
          Column({
            space: 2,
            //alignItems: HorizontalAlign.Center
          }) {
            Stack({ alignContent: Alignment.Center }) {
              Image($r('app.media.ic_top'))
                .width('100%')
                .height(200)
                .borderRadius(12)
            }
            .width('100%')
            .height(200)

            // 开放时间分两行
            Column() {
              Text('开放时间')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({
                  top: 16,
                  bottom: 8,
                  left: 16,
                  right: 16
                });
              Row({ space: 12 }) {
                Column() {
                  Text('09:00').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#800000');
                  Text('开馆时间').fontSize(14).fontColor('#7a5a3a');
                }
                .backgroundColor('#f5e5d6')
                .borderRadius(8)
                .padding({
                  top: 8,
                  bottom: 8,
                  left: 16,
                  right: 16
                });

                Column() {
                  Text('16:00').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#800000');
                  Text('停止入馆').fontSize(14).fontColor('#7a5a3a');
                }
                .backgroundColor('#f5e5d6')
                .borderRadius(8)
                .padding({
                  top: 8,
                  bottom: 8,
                  left: 16,
                  right: 16
                });
              }
              .margin({ left: 16, right: 16, bottom: 8 });

              Row({ space: 12 }) {
                Column() {
                  Text('16:30').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#800000');
                  Text('观众退场').fontSize(14).fontColor('#7a5a3a');
                }
                .backgroundColor('#f5e5d6')
                .borderRadius(8)
                .padding({
                  top: 8,
                  bottom: 8,
                  left: 16,
                  right: 16
                });

                Column() {
                  Text('17:00').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#800000');
                  Text('闭馆时间').fontSize(14).fontColor('#7a5a3a');
                }
                .backgroundColor('#f5e5d6')
                .borderRadius(8)
                .padding({
                  top: 8,
                  bottom: 8,
                  left: 16,
                  right: 16
                });
              }
              .margin({ left: 16, right: 16, bottom: 8 });

              Text('周一例行闭馆，国家法定节假日除外')
                .fontSize(14)
                .fontColor('#7a5a3a')
                .margin({ left: 16, right: 16, bottom: 8 });
            }
            .width('100%')
            .backgroundColor('#fff')
            .borderRadius(16)
            .margin({ top: 8, left: 8, right: 8 });

            // 预约方式
            Column() {
              Text('预约方式')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({
                  top: 16,
                  bottom: 8,
                  left: 16,
                  right: 16
                });
              Text('• 观众可通过中国国家博物馆官网、国家博物馆小程序和微信公众号预约入馆门票。')
                .fontSize(16)
                .fontColor('#333')
                .margin({ left: 16, right: 16, bottom: 8 });
            }
            .width('100%')
            .backgroundColor('#fff')
            .borderRadius(16)
            .margin({ top: 8, left: 8, right: 8 });

            // 进馆须知
            Column() {
              Text('进馆须知')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({
                  top: 16,
                  bottom: 8,
                  left: 16,
                  right: 16
                });
              // 分类Tab（可横向滑动）
              Scroll() {
                Row() {
                  ForEach(this.categories, (cat: string, idx: number) => {
                    Column() {
                      Text(cat)
                        .fontSize(16)
                        .fontWeight(this.selectedCategory === idx ? FontWeight.Bold : FontWeight.Normal)
                        .fontColor(this.selectedCategory === idx ? '#800000' : '#333')
                        .margin({ right: 18 })
                        .onClick(() => {
                          this.selectedCategory = idx;
                        })
                      if (this.selectedCategory === idx) {
                        Column()
                          .height(2)
                          .width(24)
                          .backgroundColor('#800000')
                          .margin({ top: 2, bottom: 8 })
                      }
                    }
                  })
                }
                .margin({ left: 20, bottom: 10, top: 10 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.On)

              // 分类内容
              Column() {
                ForEach(this.entryRules[this.selectedCategory], (rule: string) => {
                  Text(rule)
                    .fontSize(15)
                    .fontColor('#333')
                    .margin({ left: 16, right: 16, bottom: 8 });
                })
              }
              .margin({ top: 8, bottom: 16 })
            }
            .width('100%')
            .backgroundColor('#fff')
            .borderRadius(16)
            .margin({
              top: 8,
              left: 8,
              right: 8,
              bottom: 16
            });

          }
          .backgroundColor('#f5f5f5');
        }
      }
    }
  }
}
