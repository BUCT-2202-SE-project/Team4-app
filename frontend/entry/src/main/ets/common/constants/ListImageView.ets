import {ItemType} from '../../mode/type'
import http from '@ohos.net.http';
import ApiConstants from '../constants/ApiConstants';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

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
  id?: number;
}

// 新增: ArtifactItem组件
@Component
struct ArtifactItem {
  // 设置默认值
  private artifact: Artifact = {
    artifactId: 0,
    name: '',
    era: '',
    type: '',
    museum: '',
    description: '',
    imageUrl: '',
    likes: 0
  };

  // 回调函数，设置默认空函数
  private onItemClick: (artifact: Artifact) => void = (artifact: Artifact) => {
    console.info('默认点击处理函数，请提供实际处理函数');
  };

  build() {
    Column() {
      Image(this.artifact.imageUrl || $r('app.media.ic_typ1'))
        .objectFit(ImageFit.Cover)
        .aspectRatio(1.3)
        .borderRadius(12)
      Text(this.artifact.name || '')
        .fontSize(14)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 })
    }
    .onClick(() => {
      console.info(`点击文物项: ${this.artifact.name}, ID: ${this.artifact.artifactId || '未知'}`);
      this.onItemClick(this.artifact);
    })
  }
}

// 定义HTTP错误类型
interface HttpError {
  code?: number;
  message?: string;
}

@Component
export default struct ListExample {
  @State message: string = '藏品推荐';
  @State listsData: Array<ItemType> = [];
  @State artifacts: Array<Artifact> = []; // 新增: 存储转换后的文物数据
  @State isLoading: boolean = true;

  private httpRequest = http.createHttp();

  aboutToAppear() {
    this.loadTopArtifacts();
  }

  aboutToDisappear() {
    if (this.httpRequest) {
      this.httpRequest.destroy();
    }
  }

  // 保持navigateToDetail方法
  navigateToDetail(artifact: Artifact) {
    // 打印完整对象，用于调试
    console.info(`准备跳转详情，原始文物对象: ${JSON.stringify(artifact)}`);

    // 确保使用id作为主键
    const id = artifact.id || artifact.artifactId;

    if (id !== undefined) {
      console.info(`准备跳转到详情页，文物ID: ${id}`);

      // 传递id和完整对象，确保参数名称一致
      router.push({
        url: 'pages/ArtifactDetailPage',
        params: {
          id: id,
          artifactId: id, // 同时提供id和artifactId，确保与之前版本兼容
          artifact: artifact
        }
      });
      console.info(`成功跳转到详情页，文物ID: ${id}`);
    } else {
      console.error('文物ID为空，无法跳转到详情页:', JSON.stringify(artifact));
      promptAction.showToast({
        message: '无法查看详情：文物ID不存在',
        duration: 2000
      });
    }
  }

  // 加载点赞最高的文物 - 增加转换为Artifact数组
  loadTopArtifacts() {
    // 构建API URL
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
                // 按点赞数排序（从高到低）
                artifacts.sort((a, b) => (b.likes || 0) - (a.likes || 0));

                // 获取前6个
                const topArtifacts = artifacts.slice(0, 6);
                
                // 直接保存Artifact数组，方便后续使用
                this.artifacts = topArtifacts;

                // 同时保持原有的ItemType数组以兼容
                const items: ItemType[] = [];
                for (let item of topArtifacts) {
                  // 创建一个完全符合ItemType接口的对象
                  const itemObj: ItemType = {
                    id: item.artifactId,
                    title: item.name,
                    img: item.imageUrl || $r('app.media.ic_typ1'),
                    url: `pages/ArtifactDetailPage?artifactId=${item.artifactId}`
                  };
                  
                  items.push(itemObj);
                }
                this.listsData = items;
              }
            } catch (e) {
              console.error(`解析响应失败: ${e.toString()}`);
              // 加载失败时使用默认数据
              this.useDefaultData();
            }
          } else {
            console.error(`请求失败: ${err?.message || '未知错误'}`);
            // 加载失败时使用默认数据
            this.useDefaultData();
          }
          this.isLoading = false;
        }
      );
    } catch (e) {
      console.error(`发起请求异常: ${e.toString()}`);
      this.useDefaultData();
      this.isLoading = false;
    }
  }

  // 使用默认数据（当API请求失败时）
  useDefaultData() {
    this.listsData = [
      {
        title: '青花瓷',
        img: $r('app.media.ic_typ1'),
        url: 'pages/ArtifactListPage?type=瓷器'
      },
      {
        title: '书画',
        img: $r('app.media.ic_typ2'),
        url: 'pages/ArtifactListPage?type=书画'
      },
      {
        title: '货币',
        img: $r('app.media.ic_typ3'),
        url: 'pages/ArtifactListPage?type=货币'
      },
      {
        title: '玉器',
        img: $r('app.media.ic_typ4'),
        url: 'pages/ArtifactListPage?type=玉器'
      },
      {
        title: '青铜器',
        img: $r('app.media.ic_typ5'),
        url: 'pages/ArtifactListPage?type=青铜'
      },
      {
        title: '织物',
        img: $r('app.media.ic_typ6'),
        url: 'pages/ArtifactListPage?type=其他'
      }
    ];
    
    // 同时创建默认的Artifact数组，显式指定类型Artifact
    const defaultArtifacts: Artifact[] = [];
    
    for (let i = 0; i < this.listsData.length; i++) {
      const item = this.listsData[i];
      const newArtifact: Artifact = {
        artifactId: i + 1,
        id: i + 1,
        name: item.title ? item.title.toString() : '',
        era: '未知',
        type: item.title ? item.title.toString() : '未知',
        museum: '未知',
        description: '暂无描述',
        imageUrl: item.img ? item.img.toString() : '',
        likes: 0
      };
      defaultArtifacts.push(newArtifact);
    }
    
    this.artifacts = defaultArtifacts;
  }

  build() {
    Column() {
      Text('明星文物')
        .fontSize('16fp')
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin('10vp')
      //列表
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
        List({ space: 12 }) {
          // 使用artifacts数组和ArtifactItem组件
          ForEach(this.artifacts, (item: Artifact) => {
            ListItem() {
              ArtifactItem({
                artifact: item,
                onItemClick: (artifact: Artifact) => {
                  this.navigateToDetail(artifact);
                }
              })
            }
            .margin({ left: '5vp', right: '5vp' })
          })
        }
        .width('95%')
        .lanes(2) // 排列个数
      }
    }
  }
}