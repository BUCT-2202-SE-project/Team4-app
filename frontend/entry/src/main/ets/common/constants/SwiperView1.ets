@Component
export default struct SwiperExample1 {
  @State swiperData:Array<Resource> = [
    $r('app.media.ic_catering1'),
    $r('app.media.ic_catering2'),
    $r('app.media.ic_catering3'),
    $r('app.media.ic_catering4')
  ]

  build() {
    Column(){
      Swiper(){
        ForEach(this.swiperData,(item:Resource)=>{
          Image(item)
            .width('95%')
            .height('150vp')
            .borderRadius(12)
        })
      }
      .index(0) //初始化索引值
      .autoPlay(true) //自动播放
      .interval(2000) //自动播放间隔时间，默认3000
      .loop(true) //是否开启循环
      .duration(1000)  //切换的动画时长
      .itemSpace(0) //图片间隙
      .indicator(true) //是否启用导航点指示器
    }
    .width('100%')
    .margin({top:'5vp'})
  }
}