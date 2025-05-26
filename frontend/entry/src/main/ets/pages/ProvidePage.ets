
import router from '@ohos.router';
import CommonConstants from '../common/constants/CommonConstants';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import promptAction from '@ohos.promptAction';
@Entry
@Component
export default struct ProvidePage {
  @StorageProp('currentDeviceSize') currentDeviceSize: string = CommonConstants.SM;
  @State provideType: string = ''
  @State period: string = ''
  @State category: string = ''
  @State desc: string = ''
  @State source: string = ''
  @State images: (Resource|image.PixelMap)[] = []
  @State name: string = ''
  @State contact: string = ''
  @State region: string = ''
  @State address: string = ''
  @State showProvideType: boolean = false
  @State showPeriod: boolean = false
  @State showCategory: boolean = false
  @State showRegion: boolean = false

  provideTypeOptions: string[] = ['捐赠', '出售', '移交']
  periodOptions: string[] = ['1840之前', '1840~1949年']
  categoryOptions: string[] = ['古代文物', '近现代文物']
  build() {
    Stack() {
      Column() {
        // 顶部红色横幅（带返回按钮和标题，内容居中）
        Stack() {
          Column() {
            Blank()
          }
          .height(90)
          .width('100%')
          // 标题和返回按钮
          Row() {
            Image($r('app.media.ic_back'))
              .width(32)
              .height(32)
              .margin({ left: 16, top: 10 })
              .onClick(() => {
                router.back();
              })
            Blank()
            Column() {
              Text('博物馆征集文物藏品登记')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222')
                .margin({ top: 16, bottom: 0 })  // 修改 margin 调整位置
              //.alignItems(HorizontalAlign.Center)  // 确保 Text 水平居中
              Text('（以下均为必填项）')
                .fontSize(14)
                .fontColor('#666')
                .margin({ bottom: 0 })
            }
            .alignItems(HorizontalAlign.Center)
            Blank()
          }
          .width('100%')

        }

        // 表单内容（可滚动）
        Scroll() {
          Column() {
            // 卡片样式容器
            Column({ space: 16 }) {
              // 提供藏品方式
              Row() {
                Button(this.provideType || '拟提供藏品方式')
                  .backgroundColor('#fff')
                  .fontColor('#222')
                  .border({ width: '100%', color: '#e0e0e0' })
                  .borderRadius(6)
                  .onClick(() => { this.showProvideType = true })
                  .margin({ left: 12, right: 12 })
                  .backgroundColor('#e0e0e0')
                if (this.showProvideType) {
                  Column() {
                    ForEach(this.provideTypeOptions, (item: string) => {
                      Button(item)
                        .onClick(() => {
                          this.provideType = item
                          this.showProvideType = false
                        })
                    })
                    Button('取消').onClick(() => { this.showProvideType = false })
                  }
                  .backgroundColor('#fff')
                  .borderRadius(8)
                  .margin({ left: 12, right: 12, top: 4 })
                }
              }

              // 藏品时期
              Row() {
                Button(this.period || '藏品时期')
                  .backgroundColor('#fff')
                  .fontColor('#222')
                  .border({ width: '100%', color: '#e0e0e0' })
                  .borderRadius(6)
                  .onClick(() => { this.showPeriod = true })
                  .margin({ left: 12, right: 12 })
                  .backgroundColor('#e0e0e0')
                if (this.showPeriod) {
                  Column() {
                    ForEach(this.periodOptions, (item: string) => {
                      Button(item)
                        .onClick(() => {
                          this.period = item
                          this.showPeriod = false
                        })
                    })
                    Button('取消').onClick(() => { this.showPeriod = false })
                  }
                  .backgroundColor('#fff')
                  .borderRadius(8)
                  .margin({ left: 12, right: 12, top: 4 })
                }
              }
              // 文物分类
              Row() {
                Button(this.category || '文物分类')
                  .backgroundColor('#fff')
                  .fontColor('#222')
                  .border({ width: '100%', color: '#e0e0e0' })
                  .borderRadius(6)
                  .onClick(() => { this.showCategory = true })
                  .margin({ left: 12, right: 12 })
                  .backgroundColor('#e0e0e0')
                if (this.showCategory) {
                  Column() {
                    ForEach(this.categoryOptions, (item: string) => {
                      Button(item)
                        .onClick(() => {
                          this.category = item
                          this.showCategory = false
                        })
                    })
                    Button('取消').onClick(() => { this.showCategory = false })
                  }
                  .backgroundColor('#fff')
                  .borderRadius(8)
                  .margin({ left: 12, right: 12, top: 4 })
                }
              }
              // 藏品描述
              Row() {
                TextArea({ placeholder:'藏品描述（200字以内）', text: this.desc })
                  .onChange((val: string) => this.desc = val )
                  .border({ width: 1, color: '#e0e0e0' })
                  .borderRadius(6)
                  .margin({ left: 12, right: 12 })
                  .maxLength(200)
                  .height('80vp')
              }
              Text(`${this.desc.length}/200`).fontSize(12).fontColor('#888').alignSelf(ItemAlign.End).margin({ right: 16, bottom: 4 })

              // 藏品真实来源
              Row() {
                TextArea({ placeholder:'藏品真实来源（流传至您手中的经历，200字以内）', text: this.source })
                  .onChange((val: string) => this.source = val )
                  .border({ width: 1, color: '#e0e0e0' })
                  .borderRadius(6)
                  .margin({ left: 12, right: 12 })
                  .maxLength(200)
                  .height('80vp')
              }
              .margin({ bottom: 10 })
              Text(`${this.source.length}/200`).fontSize(12).fontColor('#888').alignSelf(ItemAlign.End).margin({ right: 16, bottom: 4 })
              // 藏品图片上传
              Row() {
                Text('藏品图片（请上传真实、清晰藏品图片，至少不同角度拍摄两张）')
                  .fontSize(14)
                  .fontColor('#888')
                  .margin({ left: 12, top: 16, bottom: 4 })
              }
              Row() {
                ForEach(this.images, (img: Resource|image.PixelMap, idx: number) => {
                  Image(img)
                    .width(64)
                    .height(64)
                    .margin({ right: 8 })
                })
                // 上传按钮
                Column() {
                  Text('+')
                    .fontSize(32)
                    .fontColor('#888')
                    .width(64)
                    .height(64)
                    .alignSelf(ItemAlign.Center)
                    .border({ width: 1, color: '#bbb' })
                    .backgroundColor('#fafafa')
                    .onClick(() => {
                      // 创建图片选择器
                      let picker = new photoAccessHelper.PhotoViewPicker();
                      let options: photoAccessHelper.PhotoSelectOptions = {
                        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
                        maxSelectNumber: 1 // 每次选择一张图片
                      };

                      picker.select(options).then((result: photoAccessHelper.PhotoSelectResult) => {
                        if (result && result.photoUris && result.photoUris.length > 0) {
                          let uri = result.photoUris[0];
                          try {
                            let file = fileIo.openSync(uri);
                            let source = image.createImageSource(file.fd);
                            let decodingOptions: image.DecodingOptions = {
                              editable: true,
                              desiredPixelFormat: 3
                            };

                            source.createPixelMap(decodingOptions).then((pixelMap: image.PixelMap) => {
                              // 将图片添加到images数组
                              this.images.push(pixelMap);
                            }).catch((err: BusinessError) => {
                              console.error('Failed to create PixelMap: ' + JSON.stringify(err));
                            });
                          } catch (err) {
                            console.error('Failed to process image: ' + JSON.stringify(err));
                          }
                        }
                      }).catch((err: BusinessError) => {
                        console.error('Failed to select photo: ' + JSON.stringify(err));
                      });
                    })
                }
                .alignSelf(ItemAlign.Start)
              }
              .margin({ left: 12, top: 8 })
              Text('只能上传jpg/png文件')
                .fontSize(12)
                .fontColor('#888')
                .margin({ left: 12, top: 4 })
                .margin({ bottom: 10 })
              // 姓名
              Row() {
                TextArea({ placeholder:'请输入姓名', text: this.name })
                  .onChange((val: string) => this.name = val )
                  .border({ width: 1, color: '#e0e0e0' })
                  .borderRadius(6)
                  .margin({ left: 12, right: 12 })
                  .maxLength(200)
              }
              .margin({ bottom: 10 })
              // 联系方式
              Row() {
                TextArea({ placeholder:'请输入联系方式', text: this.contact })
                  .onChange((val: string) => this.contact = val )
                  .border({ width: 1, color: '#e0e0e0' })
                  .borderRadius(6)
                  .margin({ left: 12, right: 12 })
                  .maxLength(200)
              }
              .margin({ bottom: 10 })
              // 省市区
              Row() {
                Button(this.region || '省市区')
                  .backgroundColor('#fff')
                  .fontColor('#222')
                  .border({ width: '100%', color: '#e0e0e0' })
                  .borderRadius(6)
                  .onClick(() => { this.showRegion = true })
                  .margin({ left: 12, right: 12 })
                  .backgroundColor('#e0e0e0')
                if (this.showRegion) {
                  Column() {
                    ForEach(['北京', '上海', '广东', '江苏', '其他'], (item: string) => {
                      Button(item)
                        .onClick(() => {
                          this.region = item
                          this.showRegion = false
                        })
                    })
                    Button('取消').onClick(() => { this.showRegion = false })
                  }
                  .backgroundColor('#fff')
                  .borderRadius(8)
                  .margin({ left: 12, right: 12, top: 4 })
                }
              }
              .margin({ bottom: 10 })
              // 详细地址
              Row() {
                TextArea({ placeholder:'请输入详细地址', text: this.address })
                  .onChange((val: string) => this.address = val )
                  .border({ width: 1, color: '#e0e0e0' })
                  .borderRadius(6)
                  .margin({ left: 12, right: 12 })
                  .maxLength(200)
                  .height('80vp')
              }
              Text(`${this.address.length}/200`).fontSize(12).fontColor('#888').alignSelf(ItemAlign.End).margin({ right: 16, bottom: 4 })
              // 提交重置按钮
              Row() {
                Button('提交').type(ButtonType.Normal).backgroundColor('#b71c1c').fontColor('#fff').margin({ left: 32, right: 16, top: 16, bottom: 16 })
                  .onClick(() => {
                    // 显示提交成功提示
                    promptAction.showToast({
                      message: '提交成功',
                      duration: 400
                    });
                  })
                Button('重置').type(ButtonType.Normal).backgroundColor('#eee').fontColor('#b71c1c').margin({ right: 32, top: 16, bottom: 16 })
                  .onClick(() => {
                    // 清空所有数据
                    this.provideType = '';
                    this.period = '';
                    this.category = '';
                    this.desc = '';
                    this.source = '';
                    this.images = [];
                    this.name = '';
                    this.contact = '';
                    this.region = '';
                    this.address = '';
                  })
              }
              // 保证底部有足够空白不被底栏遮挡
              Blank().height(48)
            }
          }
          .backgroundColor('#fff')
          .borderRadius(8)
          .margin({ left: 8, right: 8, top: 8, bottom: 8 })
        }
        .width('100%').flexGrow(1)
      }
      .height('100%')
      // 底部红色栏浮动在页面底部
    }
  }
}
