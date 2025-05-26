import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import http from '@ohos.net.http';
import ApiConstants from '../common/constants/ApiConstants';
import { CommonTabBar } from '../common/components/CommonTabBar';
import { UserService } from '../common/utils/UserService';
import SwiperView from '../common/constants/SwiperView';
import CommonConstants from '../common/constants/CommonConstants';
import CenterGridView from '../common/constants/CenterGridView';
import ListImageView from '../common/constants/ListImageView';
import RecommendView from '../common/constants/RecommendView';


@Entry
@Component
struct ProfilePage {
  @StorageProp('currentDeviceSize') currentDeviceSize: string = CommonConstants.SM;
  build() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('首页')
              .fontWeight(FontWeight.Medium)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .margin({
                left: this.currentDeviceSize === CommonConstants.LG ?
                $r('app.float.common_margin_larger') : $r('app.float.common_margin'),
                top: $r('app.float.common_margin'),
                bottom: $r('app.float.common_margin')
              })
              .width('50%')
            Blank()
            Image($r('app.media.ic_search'))
              .width(32)
              .height(32)
              .margin({
                right: this.currentDeviceSize === CommonConstants.LG ?
                $r('app.float.common_margin_larger') : $r('app.float.common_margin'),
                top: $r('app.float.common_margin'),
                bottom: $r('app.float.common_margin')
              })
              .objectFit(ImageFit.Contain)
              .width('50%')
              .onClick(() => {
                router.pushUrl({ url: 'pages/ImageSearchPage' })
              })
          }
          // Swiper component
          SwiperView()
          // Center grid component
          CenterGridView()
          // List image component
          ListImageView()
          RecommendView()
        }
        .width('100%')
        .backgroundColor('#F5F5F5')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 添加底部导航栏
      CommonTabBar({ currentIndex: 0 })
    }
    .width('100%')
    .height('100%')
  }
}