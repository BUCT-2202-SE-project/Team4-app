
import {ItemConfig} from '../../mode/type'
import router from '@ohos.router';
import http from '@ohos.net.http';
import ApiConstants from '../constants/ApiConstants';

// 定义文物接口
interface Artifact {
  artifactId: number;
  name: string;
  era: string;
  type: string;
  museum: string;
  description: string;
  imageUrl: string;
  likes: number;
  feature?: string;
}

// 定义HTTP错误类型
interface HttpError {
  code?: number;
  message?: string;
}

@Component
export default struct RecommendExample {
  @State private listsData: Array<ItemConfig> = [];
  @State private isLoading: boolean = true;
  // 默认数据
  private defaultListsData: Array<ItemConfig> = [
    {
      title: '瓷器',
      subtitle: '经典传承 | 精美瓷器 匠心独运',
      icon: $r('app.media.ic_typ1'),
      img: $r('app.media.ic_right'),
      url: 'pages/ArtifactListPage?type=瓷器',
    },
    {
      title: '书画',
      subtitle: '笔墨丹青 | 书画艺术 传承千年',
      icon: $r('app.media.ic_typ2'),
      img: $r('app.media.ic_right'),
      url: 'pages/ArtifactListPage?type=书画',
    },
    {
      title: '青铜',
      subtitle: '铜光闪耀 | 传世青铜 流光溢彩',
      icon: $r('app.media.ic_typ5'),
      img: $r('app.media.ic_right'),
      url: 'pages/ArtifactListPage?type=青铜',
    },
    {
      title: '玉器',
      subtitle: '玉润如水 | 精美玉器 彰显高贵',
      icon: $r('app.media.ic_typ4'),
      img: $r('app.media.ic_right'),
      url: 'pages/ArtifactListPage?type=玉器',
    },
    {
      title: '雕塑',
      subtitle: '形神兼备 | 雕塑艺术 永恒经典',
      icon: $r('app.media.ic_typ6'),
      img: $r('app.media.ic_right'),
      url: 'pages/ArtifactListPage?type=雕塑',
    },
  ];

  // 所需的文物类型
  private artifactTypes: string[] = ['瓷器', '书画', '青铜', '玉器', '雕塑'];
  private httpRequest = http.createHttp();

  aboutToAppear() {
    // 初始化列表数据为默认数据
    this.listsData = [...this.defaultListsData];
    // 加载动态数据
    this.loadArtifactsByType();
  }

  aboutToDisappear() {
    if (this.httpRequest) {
      this.httpRequest.destroy();
    }
  }

  // 加载各类型文物数据
  loadArtifactsByType() {
    // 构建API URL以获取所有文物
    const url = ApiConstants.getFullUrl(ApiConstants.API_ARTIFACTS);

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          connectTimeout: 30000,
          readTimeout: 30000
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              const resultStr = data.result ? data.result.toString() : '[]';
              const artifacts: Array<Artifact> = JSON.parse(resultStr);

              if (Array.isArray(artifacts)) {
                // 按文物类型分组
                const artifactsByType: Record<string, Artifact[]> = {};

                // 初始化类型分组
                this.artifactTypes.forEach(type => {
                  artifactsByType[type] = [];
                });

                // 将文物按类型分组
                artifacts.forEach(artifact => {
                  if (this.artifactTypes.includes(artifact.type)) {
                    artifactsByType[artifact.type].push(artifact);
                  }
                });

                // 为每种类型获取点赞最高的文物
                const dynamicListsData: Array<ItemConfig> = [];

                this.artifactTypes.forEach((type, index) => {
                  const typeArtifacts = artifactsByType[type];

                  // 按点赞数排序
                  typeArtifacts.sort((a, b) => (b.likes || 0) - (a.likes || 0));

                  const topArtifact = typeArtifacts.length > 0 ? typeArtifacts[0] : null;

                  // 创建ItemConfig对象
                  const itemConfig: ItemConfig = {
                    title: type,
                    subtitle: this.defaultListsData[index].subtitle, // 保留原始副标题
                    icon: topArtifact && topArtifact.imageUrl ? topArtifact.imageUrl : this.defaultListsData[index].icon,
                    img: $r('app.media.ic_right'),
                    url: `pages/ArtifactListPage?type=${encodeURIComponent(type)}`
                  };

                  dynamicListsData.push(itemConfig);
                });

                // 更新列表数据
                if (dynamicListsData.length > 0) {
                  this.listsData = dynamicListsData;
                }
              }
            } catch (e) {
              console.error(`解析响应失败: ${e.toString()}`);
              // 使用默认数据，已在aboutToAppear中初始化
            }
          } else {
            console.error(`请求失败: ${err?.message || '未知错误'}`);
            // 使用默认数据，已在aboutToAppear中初始化
          }
          this.isLoading = false;
        }
      );
    } catch (e) {
      console.error(`发起请求异常: ${e.toString()}`);
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Text('藏品推荐')
        .fontSize('16fp')
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin('10vp')

      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
          Text('加载中...')
            .fontSize(14)
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(16)
      } else {

        Scroll() {
                  Column({space:2}) {
                    ForEach(this.listsData, (item: ItemConfig) => {
                      Column({
                        space: 2,
                      }) {
                        Row({ space: 8 }) {
                          Column({ space: 8 }) {
                            Text(item.title)
                              .fontSize(18)
                              .fontWeight(700)
                              .alignSelf(ItemAlign.Center)
                            Text(item.subtitle)
                              .fontSize(12)
                              .fontColor('#999')
                              .alignSelf(ItemAlign.Center)
                          }
                          .width("50%")
                          .alignItems(HorizontalAlign.Start)

                            Image(item.icon)
                              .width(50)
                              .height(80)
                              .backgroundColor('#efefef')
                              .alignSelf(ItemAlign.Center)
                              .borderRadius(6)
                              .width('33.3%')
                            Image(item.img)
                              .width(20)
                              .height(20)
                              .fillColor('#999')
                              .onClick(() => {
                                router.pushUrl({ url: item.url });
                              })

                        }
                        .width('100%')
                        .height(80)
                        .backgroundColor('#fff')
                        .borderRadius(5)
                        .justifyContent(FlexAlign.SpaceBetween)
                        .onClick(() => {
                          router.pushUrl({ url: item.url });
                        })
                      }
                      .backgroundColor('#ccc')
                    })
                  }
                  // 使用链式写法设置 Column 的属性
                  .width('100%') // 确保宽度是100%
                }
                // 使用链式写法设置 Scroll 的属性
                .scrollable(ScrollDirection.Vertical) // 明确指定滚动方向为垂直
                .scrollBar(BarState.On)
                .edgeEffect(EdgeEffect.Spring)
      }
    }
  }
}
