import {ItemType} from '../../mode/type'
import router from '@ohos.router';
@Component
export default struct CenterGridView {
  @State message: string = '导航组件';
  private navData:Array<ItemType> =[
    {
      title:'全景参馆',
      img:$r('app.media.ic_love'),
      url: 'pages/PanoramaPage',
    },
    {
      title:'参观信息',
      img:$r('app.media.ic_record'),
      url: 'pages/VistPage',
    },
    {
      title:'消息通知',
      img:$r('app.media.ic_message'),
      url: 'pages/MessagePage',
    },
    {
      title:'公益讲解',
      img:$r('app.media.ic_shopping'),
      url: 'pages/LecturePage',
    },
    {
      title:'餐饮服务',
      img:$r('app.media.ic_target'),
      url: 'pages/CateringPage',
    },
    {
      title:'便民服务',
      img:$r('app.media.ic_privacy'),
      url: 'pages/ServicePage',
    },
    {
      title:'藏品文创',
      img:$r('app.media.ic_favorite'),
      url: 'pages/CulturalPage',
    },
    {
      title:'藏品好课',
      img:$r('app.media.ic_recycle'),
      url: 'pages/ClassPage',
    }
  ]

  build() {
    Column(){
      Grid(){
        ForEach(this.navData,(item:ItemType)=>{
          GridItem(){
            Column(){
              Image(item.img)
                .width('25vp')
                .height('25vp')
                .borderRadius(10)
                .onClick(() => {
                  // 点击图片时跳转到相应的页面
                  router.pushUrl({ url: item.url });
                });
              Text(item.title)
                .fontSize('14fp')
                .margin({top:'4vp'})
                .onClick(() => {
                  // 点击图片时跳转到相应的页面
                  router.pushUrl({ url: item.url });
                });
            }
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .height('120vp')
      .rowsGap('12vp') //设置行与行的间距。
      .columnsGap('8vp') //设置列与列的间距。
      .backgroundColor(Color.White)
      .width('95%')
      .margin('13vp')
      .padding({
        top:'10vp',
        bottom:'10vp'
      })
    }
  }
}