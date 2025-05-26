
import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import ApiConstants from '../common/constants/ApiConstants';
import { CommonTabBar } from '../common/components/CommonTabBar';

// 定义HTTP错误类型
interface HttpError {
  code?: number;
  message?: string;
}

// 定义文物接口
interface Artifact {
  id: number;            // 使用id作为主键，与后端保持一致
  name: string;
  era: string;
  type: string;
  museum: string;
  description: string;
  imageUrl: string;
  likes: number;
  dynasty?: string;      // 添加后端返回的其他字段
  category?: string;     // 添加后端返回的其他字段
}

// API响应接口
interface ApiResponse {
  success: boolean;
  message?: string;
  data?: Artifact[];
}

// 定义HTTP请求回调函数的类
class HttpCallbackClass {
  onResponse(err: HttpError | null, data: http.HttpResponse): void {
  }
}

@Entry
@Component
struct ArtifactListPage {
  @State artifacts: Array<Artifact> = [];
  @State filteredArtifacts: Array<Artifact> = []; // 添加过滤后的文物数组
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State errorMsg: string = '';
  @State searchKeyword: string = ''; // 添加搜索关键词状态

  // 汉字拼音映射字典 - 常用汉字的拼音首字母
  private pinyinMap: Record<string, string> = {
    '瓷': 'ci', '器': 'qi', '书': 'shu', '画': 'hua', '青': 'qing', '铜': 'tong',
    '玉': 'yu', '雕': 'diao', '塑': 'su', '文': 'wen', '物': 'wu', '馆': 'guan',
    '唐': 'tang', '宋': 'song', '元': 'yuan', '明': 'ming', '清': 'qing', '代': 'dai',
    '古': 'gu', '今': 'jin', '中': 'zhong', '国': 'guo', '博': 'bo', '珍': 'zhen',
    '贵': 'gui', '历': 'li', '史': 'shi', '陶': 'tao', '瓯': 'ou', '彩': 'cai',
    '金': 'jin', '银': 'yin', '铁': 'tie', '石': 'shi', '木': 'mu', '竹': 'zhu',
    '丝': 'si', '绸': 'chou', '绣': 'xiu', '工': 'gong', '艺': 'yi', '品': 'pin'
  };

  private httpRequest = http.createHttp();
  // 文物类型过滤选项
  private artifactTypes: string[] = ['全部', '瓷器', '书画', '青铜', '玉器', '雕塑', '其他'];

  aboutToAppear() {
    this.loadArtifacts();
  }

  // 添加页面显示时的生命周期函数，确保从详情页返回时更新点赞数
  onPageShow() {
    console.info('文物列表页面重新显示，刷新数据');
    // 保持当前的选项卡，刷新对应类型的文物数据
    this.loadArtifacts(this.artifactTypes[this.currentTab]);
  }

  aboutToDisappear() {
    if (this.httpRequest) {
      this.httpRequest.destroy();
    }
  }

  // 将中文转换为拼音
  toPinyin(text: string): string {
    let result = '';
    for(let i = 0; i < text.length; i++) {
      const char = text[i];
      // 如果是中文字符，尝试转换为拼音
      if(/[\u4e00-\u9fa5]/.test(char)) {
        result += this.pinyinMap[char] || char;
      } else {
        // 非中文字符保持不变
        result += char;
      }
    }
    return result.toLowerCase();
  }

  // 检查是否匹配拼音
  matchesPinyin(text: string, keyword: string): boolean {
    // 将文本转为拼音
    const textPinyin = this.toPinyin(text);
    // 检查拼音是否包含关键词
    return textPinyin.includes(keyword.toLowerCase());
  }

  loadArtifacts(type: string = '') {
    this.isLoading = true;
    this.errorMsg = '';

    // 构建API URL
    let url = ApiConstants.getFullUrl(ApiConstants.API_ARTIFACTS);
    if (type && type !== '全部') {
      url += `/type/${encodeURIComponent(type)}`;
    }

    console.info(`开始请求文物数据，URL: ${url}`);
    promptAction.showToast({
      message: '正在加载文物数据...',
      duration: 1500
    });

    try {
      this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          connectTimeout: 30000, // 30秒连接超时
          readTimeout: 30000     // 30秒读取超时
        },
        (err: HttpError | null, data: http.HttpResponse) => {
          if (!err && data.responseCode === 200) {
            try {
              console.info(`成功接收到响应，状态码: ${data.responseCode}`);
              console.info(`响应数据: ${data.result}`);

              const resultStr = data.result ? data.result.toString() : '[]';
              console.info(`转换为字符串: ${resultStr.substring(0, 100)}...`); // 只记录前100个字符避免日志过长

              const result: Array<Artifact> = JSON.parse(resultStr);
              if (Array.isArray(result)) {
                this.artifacts = result;
                console.info(`成功解析为数组，包含${this.artifacts.length}个项目`);

                // 记录第一个项目的详细信息，便于调试
                if (this.artifacts.length > 0) {
                  console.info(`第一个文物示例: ${JSON.stringify(this.artifacts[0])}`);
                }

                this.updateFilteredArtifacts(); // 更新过滤后的文物列表

                if (this.artifacts.length === 0) {
                  console.warn('获取到空数组，没有文物数据');
                  this.errorMsg = '暂无数据';
                  promptAction.showToast({
                    message: '暂无文物数据',
                    duration: 2000
                  });
                } else {
                  promptAction.showToast({
                    message: `已加载${this.artifacts.length}个文物`,
                    duration: 2000
                  });
                }
              } else {
                console.error(`API返回的数据不是数组: ${typeof result}`);
                this.errorMsg = '数据格式错误：返回的不是数组';
                this.artifacts = [];
                this.filteredArtifacts = [];
                promptAction.showToast({
                  message: '数据格式错误',
                  duration: 2000
                });
              }
            } catch (e) {
              console.error(`解析响应失败: ${e.toString()}`);
              console.error(`原始响应数据: ${data.result?.toString().substring(0, 200) || '空'}`);
              this.errorMsg = `解析数据失败: ${e.toString()}`;
              this.artifacts = [];
              this.filteredArtifacts = [];
              promptAction.showToast({
                message: '解析数据失败',
                duration: 2000
              });
            }
          } else {
            const errMsg = err ? err.message : '未知错误';
            const respCode = data ? data.responseCode.toString() : 'N/A';
            console.error(`请求失败: ${errMsg}, 响应码: ${respCode}`);
            this.errorMsg = `网络请求失败: ${errMsg}, 响应码: ${respCode}`;
            this.artifacts = [];
            this.filteredArtifacts = [];
            promptAction.showToast({
              message: `网络错误: ${errMsg}`,
              duration: 3000
            });
          }
          this.isLoading = false;
        }
      );
    } catch (e) {
      console.error(`发起请求异常: ${e.toString()}`);
      this.errorMsg = `发起请求异常: ${e.toString()}`;
      this.isLoading = false;
      this.artifacts = [];
      this.filteredArtifacts = [];
      promptAction.showToast({
        message: '网络连接异常',
        duration: 3000
      });
    }
  }

  // 添加关键词搜索方法
  updateFilteredArtifacts() {
    if (!this.searchKeyword || this.searchKeyword.trim() === '') {
      // 如果没有搜索关键词，显示所有文物
      this.filteredArtifacts = [...this.artifacts];
      return;
    }

    // 使用关键词对文物进行过滤
    const keyword = this.searchKeyword.toLowerCase().trim();
    console.info(`执行搜索，关键词: "${keyword}"`);

    this.filteredArtifacts = this.artifacts.filter(item => {
      // 直接文本匹配
      const nameMatch = item.name.toLowerCase().includes(keyword);
      const descMatch = item.description?.toLowerCase().includes(keyword) || false;
      const typeMatch = item.type.toLowerCase().includes(keyword);
      const eraMatch = item.era.toLowerCase().includes(keyword);

      // 拼音匹配
      const namePinyinMatch = this.matchesPinyin(item.name, keyword);
      const typePinyinMatch = this.matchesPinyin(item.type, keyword);
      const eraPinyinMatch = this.matchesPinyin(item.era, keyword);

      const isMatch = nameMatch || descMatch || typeMatch || eraMatch ||
        namePinyinMatch || typePinyinMatch || eraPinyinMatch;

      // 记录匹配结果
      if (isMatch) {
        let matchType = nameMatch ? '名称匹配' :
          descMatch ? '描述匹配' :
            typeMatch ? '类型匹配' :
              eraMatch ? '年代匹配' :
                namePinyinMatch ? '名称拼音匹配' :
                  typePinyinMatch ? '类型拼音匹配' :
                    '年代拼音匹配';
        console.info(`匹配到文物: ${item.name}, 匹配类型: ${matchType}`);
      }

      return isMatch;
    });

    console.info(`搜索完成，找到 ${this.filteredArtifacts.length} 条匹配结果`);

    // 如果过滤后没有结果，显示提示
    if (this.filteredArtifacts.length === 0) {
      this.errorMsg = `未找到与"${this.searchKeyword}"相关的文物`;
    } else {
      this.errorMsg = '';
    }
  }

  // 跳转到文物详情页面
  navigateToDetail(artifact: Artifact) {
    // 打印完整对象，用于调试
    console.info(`准备跳转详情，原始文物对象: ${JSON.stringify(artifact)}`);

    // 确保使用id作为主键
    const id = artifact.id;

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

  build() {
    Column() {
      // 顶部标题
      Text($r('app.string.artifacts_title'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 20, bottom: 16, left: 16 })
        .width('100%')
      // 添加搜索框
      Row() {
        TextInput({
          placeholder: '请输入关键词或拼音搜索文物...',
          text: this.searchKeyword
        })
          .placeholderColor('#999999')
          .placeholderFont({ size: 14 })
          .backgroundColor('#F5F5F5')
          .height(40)
          .border({ radius: 20 })
          .padding({ left: 16, right: 16 })
          .layoutWeight(1)
          .type(InputType.Normal)
          .fontSize(16)
          .fontColor('#333333')
          .maxLength(50)
          .onChange((value: string) => {
            // 只更新搜索关键词，不执行搜索
            console.info(`输入变化: "${value}"`);
            this.searchKeyword = value;
          })
        // 图像搜索按钮
        Button({ type: ButtonType.Normal }) {
          // 使用简单的相机图标文本表示，确保兼容性
          Text('📷')
            .fontSize(20)
            .fontColor('#333333')
        }
        .height(40)
        .width(40)
        .margin({ left: 8 })
        .backgroundColor('#F0F0F0')
        .borderRadius(20)        .onClick(() => {
          console.info('跳转到图像搜索页面');
          router.pushUrl({
            url: 'pages/ImageSearchPage'
          }).catch((err: Error | object) => {
            const errorMsg = err instanceof Error ? err.message : JSON.stringify(err);
            console.error(`跳转到图像搜索页失败: ${errorMsg}`);
            promptAction.showToast({
              message: '跳转失败',
              duration: 2000
            });
          });
        })

        // 搜索按钮
        Button('搜索', { type: ButtonType.Normal })
          .height(40)
          .width(80)
          .margin({ left: 8 })
          .backgroundColor('#4E86FF')
          .onClick(() => {
            console.info(`点击搜索按钮，搜索关键词: "${this.searchKeyword}"`);
            // 只有点击搜索按钮时才执行搜索
            this.updateFilteredArtifacts();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })

      // 错误提示（如果有）
      if (this.errorMsg !== '') {
        Text(this.errorMsg)
          .fontSize(14)
          .fontColor('#FF0000')
          .padding(16)
          .width('100%')
      }
      Column() {
                Text('欢迎使用掌上博物馆')
                  .fontSize(16)
                  .fontColor('#666')
                  .margin({ top: 18, bottom: 4 })
                Text('征集文物藏品记录')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#888')
              }
              .width('98%')
              .height(100)
              .borderRadius(12)
              .backgroundColor('#e0e0e0')
              .backgroundImage($r('app.media.ic_collect'))
              .margin({ left: '4%', right: '4%', bottom: 16 })
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                router.pushUrl({ url: 'pages/ProvidePage' })
              })
      // 文物类型选项卡
      Tabs({
        barPosition: BarPosition.Start,
        index: this.currentTab
      }) {
        ForEach(this.artifactTypes, (type: string, index: number) => {
          TabContent() {
            if (this.isLoading) {
              // 加载中显示
              Column() {
                LoadingProgress()
                  .width(50)
                  .height(50)
                Text('加载中...')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ top: 8 })
              }
              .height('100%')
              .width('100%')
              .justifyContent(FlexAlign.Center)
            } else if (this.filteredArtifacts.length === 0) {
              // 无数据显示
              Column() {
                Text('暂无数据')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .height('100%')
              .width('100%')
              .justifyContent(FlexAlign.Center)
            } else {
              // 文物列表
              List() {
                ForEach(this.filteredArtifacts, (item: Artifact) => {
                  ListItem() {
                    Column() {
                      Row() {
                        // 文物图片（或占位图）
                        Stack() {
                          if (item.imageUrl) {
                            Image(item.imageUrl)
                              .width(120)
                              .height(120)
                              .objectFit(ImageFit.Cover)
                              .borderRadius(8)
                          } else {
                            // 占位图
                            Column() {
                            }
                            .width(120)
                            .height(120)
                            .backgroundColor('#DDDDDD')
                            .borderRadius(8)
                          }
                        }
                        .margin({ right: 16 })

                        // 文物信息
                        Column() {
                          Text(item.name || '未命名文物')
                            .fontSize(18)
                            .fontWeight(FontWeight.Medium)
                            .margin({ bottom: 8 })

                          // 朝代和类型信息使用更清晰的样式
                          Row() {
                            Text('朝代: ')
                              .fontSize(14)
                              .fontColor('#666666')
                            Text(item.era || '未知')
                              .fontSize(14)
                              .fontWeight(FontWeight.Medium)
                              .fontColor('#333333')
                          }
                          .margin({ bottom: 6 })
                          .width('100%')
                          Row() {
                            Text('类型: ')
                              .fontSize(14)
                              .fontColor('#666666')
                            Text(item.type || '未知')
                              .fontSize(14)
                              .fontWeight(FontWeight.Medium)
                              .fontColor('#333333')
                          }
                          .margin({ bottom: 6 })
                          .width('100%')

                          Row() {
                            Text('博物馆: ')
                              .fontSize(14)
                              .fontColor('#666666')
                            Text(item.museum || '未知')
                              .fontSize(14)
                              .fontWeight(FontWeight.Medium)
                              .fontColor('#333333')
                          }
                          .margin({ bottom: 6 })
                          .width('100%')

                          // 点赞信息 - 仅显示点赞数
                          Row() {
                            // 使用文字代替图标
                            Text('👍')
                              .fontSize(16)
                              .margin({ right: 4 })

                            Text(`${item.likes || 0}`)
                              .fontSize(14)
                              .fontColor('#666666')
                          }
                          .margin({ top: 4 })
                        }
                        .layoutWeight(1)
                        .alignItems(HorizontalAlign.Start)
                      }

                      // 文物描述
                      Text(item.description || '暂无描述')
                        .fontSize(14)
                        .fontColor($r('app.color.text_secondary'))
                        .margin({ top: 12 })
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('100%')
                    .padding(16)
                    .borderRadius(12)
                    .backgroundColor('#FFFFFF')
                    .onClick(() => {
                      // 跳转到文物详情页面，确保传递正确参数
                      try {
                        console.info(`准备跳转到详情页，文物ID: ${item.id}`);
                        router.pushUrl({
                          url: 'pages/ArtifactDetailPage',
                          params: {
                            artifactId: item.id,
                            id: item.id, // 添加id参数，确保兼容性
                            artifact: item // 添加完整对象
                          }
                        }, (err) => {
                          if (err) {
                            console.error(`跳转到详情页失败: ${JSON.stringify(err)}`);
                            promptAction.showToast({
                              message: `跳转失败: ${err.message}`,
                              duration: 2000,
                            });
                          } else {
                            console.info(`成功跳转到详情页，文物ID: ${item.id}`);
                          }
                        });
                      } catch (error) {
                        console.error(`跳转异常: ${error}`);
                        promptAction.showToast({
                          message: `跳转异常: ${error}`,
                          duration: 2000,
                        });
                      }
                    })
                  }
                  .margin({ bottom: 12 })
                })
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
              .layoutWeight(1)
            }
          }
          .tabBar(type)
        })
      }
      .onChange((index) => {
        this.currentTab = index;
        this.loadArtifacts(this.artifactTypes[index]);
      })
      .height('80%') // 调整高度以适应底部导航栏
      .layoutWeight(1)
      // 底部导航栏
      CommonTabBar({ currentIndex: 1 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }
}
