import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import fs from '@ohos.file.fs';
import buffer from '@ohos.buffer';
import resourceManager from '@ohos.resourceManager';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import common from '@ohos.app.ability.common';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import ApiConstants from '../common/constants/ApiConstants';
import prompt from '@ohos.promptAction';

// 定义错误响应接口
interface ErrorResponse {
  message?: string;
  status?: number;
  error?: string;
}

// 统一定义文物接口，确保字段名称一致
interface Artifact {
  artifactId: number;  // 使用artifactId作为主键
  name: string;
  era: string;
  type: string;
  museum: string;
  description: string;
  imageUrl: string;
  likes: number;
  feature?: string;
  similarity?: number; // 保留相似度字段(图像搜索结果特有)
  // 兼容性字段，以防其他地方使用了id
  id?: number;
}

// API响应接口
interface ApiResponse {
  success: boolean;
  message?: string;
  data?: Artifact[];
}

// 单个文物项组件 - 从SearchResults.ets集成
@Component
struct ArtifactItem {
    // 修复: 添加默认值以解决初始化错误，使用统一接口
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

  // 修复: 添加默认的空函数作为初始值
  private onItemClick: (artifact: Artifact) => void = (artifact: Artifact) => {
    console.info('默认点击处理函数，请提供实际处理函数');
  };

  build() {
    Column() {
      Row() {
        Image(this.artifact.imageUrl || '')
          .width(80)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .backgroundColor('#F0F0F0')

        Column() {
          Text(this.artifact.name || '未知名称')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${this.artifact.era || '未知时代'} · ${this.artifact.type || '未知类型'}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({top: 4, bottom: 4})

          if (this.artifact.similarity !== undefined) {
            // 显示相似度信息，确保格式正确
            // Text(`相似度: ${typeof this.artifact.similarity === 'number' ?
            //   (this.artifact.similarity * 100).toFixed(2) + '%' :
            // this.artifact.similarity}`)
            Text(`相似度: ${typeof this.artifact.similarity === 'number' ?
              (this.artifact.similarity * 100).toFixed(2) + '%' :
              parseFloat(this.artifact.similarity) ?
                (parseFloat(this.artifact.similarity) * 100).toFixed(2) + '%' :
                'N/A'}`)
              .fontSize(14)
              .fontColor('#3366FF')
              .fontWeight(FontWeight.Bold)
              .margin({top: 4})
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({left: 12})

        Text('>')
          .fontSize(18)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .margin({bottom: 8})
      .onClick(() => {
        // 添加调试日志以便排查问题，优先使用artifactId
        console.info(`点击文物项: ${this.artifact.name}, ID: ${this.artifact.artifactId || '未知'}, 完整对象: ${JSON.stringify(this.artifact)}`);
        this.onItemClick(this.artifact);
      })
    }
  }
}

@Entry
@Component
struct ImageSearchPage {
  @State isLoading: boolean = false;
  @State searchResults: Artifact[] = [];
  @State errorMsg: string = '';
  @State selectedImage: string = '';
  @State showResults: boolean = false;
  @State previewImage: PixelMap | null = null;
  @State isPreviewReady: boolean = false;
  @State searchButtonDisabled: boolean = true;
  @State permissionGranted: boolean = false; // 添加权限状态
  @State imagePath: string = '';
  @State hasResults: boolean = false;

  // 示例图片路径 - 只有一个
  private sampleImagePath: string = 'internal://app/resources/rawfile/sample_artifact.jpg';
  private selectedImageData: buffer.Buffer | null = null;

  private httpRequest = http.createHttp();

  aboutToAppear() {
    // 在页面出现前检查权限
    this.checkAndRequestPermissions();
  }

  // 修改后的权限检查和请求方法 - 增强错误处理
  async checkAndRequestPermissions() {
    try {
      // 获取应用程序的tokenId
      try {
        const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
        if (!bundleInfo || !bundleInfo.appInfo) {
          console.error('获取应用信息失败: bundleInfo或appInfo为空');
          this.permissionGranted = true; // 默认授予权限以允许应用继续运行
          return;
        }

        const tokenId = bundleInfo.appInfo.accessTokenId;
        console.info(`成功获取应用tokenId: ${tokenId}`);

        // 创建 AtManager 实例
        const atManager = abilityAccessCtrl.createAtManager();

        // 需要请求的媒体权限
        const permissionName = 'ohos.permission.READ_MEDIA';

        try {
          // 检查权限状态
          const result = await atManager.checkAccessToken(tokenId, permissionName);
          if (result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
            this.permissionGranted = true;
            console.info('已获取媒体权限');
          } else {
            // 请求权限
            const context = getContext(this) as common.UIAbilityContext;
            await atManager.requestPermissionsFromUser(context, [permissionName]);

            // 再次检查权限是否被授予
            const checkResult = await atManager.checkAccessToken(tokenId, permissionName);
            if (checkResult === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
              this.permissionGranted = true;
              console.info('用户授予了媒体权限');
            } else {
              this.permissionGranted = false;
              this.errorMsg = '未获取媒体访问权限，可能无法选择图片';
              console.error('用户拒绝了权限请求');
            }
          }
        } catch (err) {
          console.error(`请求权限时出错: ${err instanceof Error ? err.message : JSON.stringify(err)}`);
          // 即使权限请求失败，也继续使用应用
          this.permissionGranted = true;
        }
      } catch (bundleError) {
        console.error(`获取应用信息失败: ${bundleError instanceof Error ? bundleError.message : JSON.stringify(bundleError)}`);
        // 在模拟器上获取应用信息可能失败，仍然继续使用
        this.permissionGranted = true;
      }
    } catch (error) {
      console.error(`权限检查发生未预期错误: ${error instanceof Error ? error.message : JSON.stringify(error)}`);
      // 权限处理失败时，假设已获取权限以避免阻塞用户体验
      this.permissionGranted = true;
    }
  }

  aboutToDisappear() {
    this.httpRequest.destroy();

    // 释放图片资源
    if (this.previewImage) {
      this.previewImage.release();
      this.previewImage = null;
    }
  }

  // 使用新的PhotoAccessHelper API选择图片
  async selectImageWithPhotoHelper() {
    try {
      this.isLoading = true;
      this.errorMsg = '';

      // 清理旧的预览
      if (this.previewImage) {
        this.previewImage.release();
        this.previewImage = null;
        this.isPreviewReady = false;
      }

      // 创建照片选择器
      let picker = new photoAccessHelper.PhotoViewPicker();
      let options: photoAccessHelper.PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      };

      console.info('打开图片选择器...');
      promptAction.showToast({ message: '请选择一张图片' });

      // 选择图片
      try {
        const photoResult = await picker.select(options);

        if (photoResult && photoResult.photoUris && photoResult.photoUris.length > 0) {
          const photoUri = photoResult.photoUris[0];
          console.info(`选择了图片: ${photoUri}`);

          // 显示处理提示
          promptAction.showToast({
            message: '正在处理图片...',
            duration: 2000
          });

          // 打开文件
          const file = fileIo.openSync(photoUri);

          // 创建图像源
          const imgSource = image.createImageSource(file.fd);
          if (!imgSource) {
            throw new Error("无法从文件创建图像源");
          }

          // 获取图像信息
          const imageInfo = await imgSource.getImageInfo();
          console.info(`图像信息: 宽=${imageInfo.size.width}, 高=${imageInfo.size.height}`);

          // 缩小图像尺寸
          const maxDimension = 800;
          let targetWidth = imageInfo.size.width;
          let targetHeight = imageInfo.size.height;

          if (targetWidth > maxDimension || targetHeight > maxDimension) {
            if (targetWidth > targetHeight) {
              targetHeight = Math.floor(targetHeight * (maxDimension / targetWidth));
              targetWidth = maxDimension;
            } else {
              targetWidth = Math.floor(targetWidth * (maxDimension / targetHeight));
              targetHeight = maxDimension;
            }
          }

          // 创建解码选项
          const decodingOptions: image.DecodingOptions = {
            desiredSize: { width: targetWidth, height: targetHeight },
            editable: true,
            desiredPixelFormat: image.PixelMapFormat.RGBA_8888
          };

          // 创建像素图
          this.previewImage = await imgSource.createPixelMap(decodingOptions);

          // 释放资源
          imgSource.release();
          fileIo.closeSync(file.fd);

          if (!this.previewImage) {
            throw new Error("创建像素图失败");
          }

          // 获取图像数据
          const imagePackerApi = image.createImagePacker();

          // 使用标准JPEG格式和高质量
          const packOptions: image.PackingOption = {
            format: 'image/jpeg',
            quality: 95
          };

          const imageData = await imagePackerApi.packing(this.previewImage, packOptions);
          imagePackerApi.release();

          if (!imageData || imageData.byteLength === 0) {
            throw new Error("无法获取图像数据");
          }

          // 使用Buffer存储数据
          this.selectedImageData = buffer.from(imageData);
          this.selectedImage = photoUri;
          this.searchButtonDisabled = false;
          this.isPreviewReady = true;

          console.info(`图像处理成功完成，数据大小: ${this.selectedImageData.length} 字节`);
          promptAction.showToast({ message: '图片准备完成' });
        } else {
          console.info('用户取消了选择');
          promptAction.showToast({ message: '未选择图片' });
        }
      } catch (err) {
        console.error(`选择图片失败: ${JSON.stringify(err)}`);
        this.errorMsg = `选择图片失败: ${err instanceof Error ? err.message : String(err)}`;
        promptAction.showToast({ message: '选择图片失败，使用示例图片' });
        await this.useSampleImage();
      }
    } catch (finalError) {
      console.error(`图片选择过程出现严重错误: ${JSON.stringify(finalError)}`);
      this.errorMsg = `选择图片失败: ${finalError instanceof Error ? finalError.message : String(finalError)}`;
      promptAction.showToast({ message: '图片选择失败', duration: 3000 });
    } finally {
      this.isLoading = false;
    }
  }

  // 新增方法：处理选择的图片 - 修复类型错误
  async processSelectedImage(photoUri: string): Promise<void> {
    try {
      // 记录更多信息以便调试
      console.info(`处理图片URI: ${photoUri}`);

      // 方法1: 尝试使用直接创建图像源
      try {
        console.info("尝试方法1: 直接创建图像源");

        // 创建图像源 - 修改声明方式
        const imgSource = image.createImageSource(photoUri);
        if (!imgSource) {
          throw new Error("创建图像源失败，返回null");
        }

        // 获取图像信息
        const imageInfo = await imgSource.getImageInfo();
        console.info(`图像信息: ${JSON.stringify(imageInfo)}`);

        // 如果图像太大，设置合理的解码大小
        const maxSize = 1024;
        let targetWidth = imageInfo.size.width;
        let targetHeight = imageInfo.size.height;

        if (targetWidth > maxSize || targetHeight > maxSize) {
          if (targetWidth > targetHeight) {
            targetHeight = Math.floor(targetHeight * (maxSize / targetWidth));
            targetWidth = maxSize;
          } else {
            targetWidth = Math.floor(targetWidth * (maxSize / targetHeight));
            targetHeight = maxSize;
          }
        }

        // 创建解码选项
        const decodingOptions: image.DecodingOptions = {
          desiredSize: {
            width: targetWidth,
            height: targetHeight
          },
          desiredPixelFormat: image.PixelMapFormat.RGBA_8888
        };

        console.info(`设置解码尺寸: ${targetWidth}x${targetHeight}`);

        // 创建像素图
        this.previewImage = await imgSource.createPixelMap(decodingOptions);

        if (!this.previewImage) {
          throw new Error("创建像素图返回null");
        }

        // 释放图像源
        imgSource.release();

        this.isPreviewReady = true;
        this.selectedImage = photoUri;

        // 获取图像数据
        const imageData = await this.getPixelMapData(this.previewImage);

        if (!imageData || imageData.byteLength === 0) {
          throw new Error("获取图像数据失败，大小为0");
        }

        this.selectedImageData = buffer.from(imageData);

        console.info(`成功处理图片，大小: ${this.selectedImageData.length} 字节`);
        this.searchButtonDisabled = false;

        promptAction.showToast({ message: '图片加载成功' });
        return;
      } catch (err) {
        console.error(`方法1失败: ${err instanceof Error ? err.message : String(err)}`);

        // 直接使用备用图像代替
        console.info("使用备用图像");
        await this.createBackupImage();

        this.selectedImage = 'backup_image.jpg';
        this.searchButtonDisabled = false;

        promptAction.showToast({
          message: '图片处理失败，使用备用图像',
          duration: 3000
        });
      }
    } catch (finalError) {
      console.error(`图片处理最终失败: ${finalError instanceof Error ? finalError.message : String(finalError)}`);
      this.errorMsg = `无法处理选中的图片: ${finalError instanceof Error ? finalError.message : '未知错误'}`;
      promptAction.showToast({ message: '图片处理失败' });

      // 使用示例图片作为最后的后备选择
      await this.useSampleImage();
    }
  }

  // 创建备用图像 - 增强版，确保可以预览
  async createBackupImage(): Promise<boolean> {
    console.info("创建备用图像");

    // 清理旧的预览图片
    if (this.previewImage) {
      this.previewImage.release();
      this.previewImage = null;
    }

    // 创建彩色渐变图像
    const width = 256;
    const height = 256;
    const mockImageSize = width * height * 4; // RGBA格式
    const mockImageData = new ArrayBuffer(mockImageSize);
    const dataView = new Uint8Array(mockImageData);

    // 使用更鲜明的橙色渐变，接近博物馆文物色调
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const pos = (y * width + x) * 4;
        dataView[pos] = Math.min(255, 180 + Math.floor(y / height * 75)); // R
        dataView[pos + 1] = Math.min(255, 100 + Math.floor(x / width * 55)); // G
        dataView[pos + 2] = 50; // B 低蓝色
        dataView[pos + 3] = 255; // Alpha
      }
    }

    // 添加一个文物形状
    const centerX = width / 2;
    const centerY = height / 2;
    const radius = Math.min(width, height) / 3;

    // 绘制花瓶形状
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        // 计算相对于中心的位置
        const normalizedX = (x - centerX) / radius;
        const normalizedY = (y - centerY) / radius;

        // 花瓶形状
        const vaseShape = Math.abs(normalizedX) * 2 <
          (0.5 + 0.5 * Math.sin(normalizedY * 3)) &&
          normalizedY > -1.2 && normalizedY < 1.2;

        if (vaseShape) {
          const pos = (y * width + x) * 4;
          dataView[pos] = 220;     // 陶器红色
          dataView[pos + 1] = 200; // G
          dataView[pos + 2] = 180; // B
        }
      }
    }

    // 保存数据
    this.selectedImageData = buffer.from(mockImageData);
    this.selectedImage = 'backup_image.jpg';

    try {
      // 创建预览图像
      const imageSource = image.createImageSource(this.selectedImageData.buffer);
      if (!imageSource) {
        throw new Error("创建图像源失败");
      }

      // 使用默认选项创建PixelMap
      this.previewImage = await imageSource.createPixelMap();
      imageSource.release();

      if (this.previewImage) {
        // 使用setTimeout强制更新UI状态
        setTimeout(() => {
          this.isPreviewReady = true;
          console.info('备用图像预览标志设置为true');
        }, 100);

        this.searchButtonDisabled = false;
        console.info('备用图像预览创建成功');

        return true;
      } else {
        throw new Error("创建备用图像预览失败");
      }
    } catch (err) {
      console.error(`创建备用图像预览失败: ${err}`);
      this.isPreviewReady = false;
      this.previewImage = null;
      return false;
    }
  }

  // 使用项目中真实的JPEG样本图片
  async useSampleImage() {
    try {
      this.isLoading = true;
      this.errorMsg = '';
      this.showResults = false;

      // 清理旧的预览图片
      if (this.previewImage) {
        this.previewImage.release();
        this.previewImage = null;
      }

      console.info('加载项目中的样本JPEG图片');

      // 使用相对路径指向rawfile文件夹中的图片
      const samplePath = 'resource://rawfile/sample_artifact.jpg';

      try {
        // 使用resourceManager加载图片
        const context = getContext(this) as common.UIAbilityContext;
        const resourceMgr = context.resourceManager;

        console.info(`尝试加载资源: ${samplePath}`);

        // 从资源文件加载图片
        const imageData = await resourceMgr.getRawFileContent(samplePath);
        console.info(`成功加载样本图片, 大小: ${imageData.byteLength} 字节`);

        // 检查JPEG头部标识
        const dataView = new Uint8Array(imageData);
        if (dataView[0] === 0xFF && dataView[1] === 0xD8) {
          console.info('验证成功: 正确的JPEG头部');
        } else {
          console.warn(`警告: 样本图像可能不是标准JPEG格式! 头部: ${dataView[0].toString(16)} ${dataView[1].toString(16)}`);
        }

        // 打印头部十六进制值进行调试
        let hexPrefix = '';
        for (let i = 0; i < Math.min(16, dataView.length); i++) {
          hexPrefix += ` ${dataView[i].toString(16).padStart(2, '0')}`;
        }
        console.info(`图像数据头部(十六进制):${hexPrefix}`);

        // 创建Buffer
        this.selectedImageData = buffer.from(imageData);
        this.selectedImage = 'sample_artifact.jpg';

        // 创建图像源供预览
        try {
          const imageSource = image.createImageSource(imageData);
          if (!imageSource) {
            throw new Error('无法创建图像源');
          }

          // 创建像素图
          this.previewImage = await imageSource.createPixelMap();
          imageSource.release();

          if (this.previewImage) {
            this.isPreviewReady = true;
            console.info('预览图像创建成功');

            // 获取预览图像信息
            const imageInfo = await this.previewImage.getImageInfo();
            console.info(`预览图像尺寸: ${imageInfo.size.width}x${imageInfo.size.height}`);
          }
        } catch (previewError) {
          console.error(`预览创建失败: ${JSON.stringify(previewError)}`);
          this.isPreviewReady = false;
        }

        // 允许搜索
        this.searchButtonDisabled = false;
        promptAction.showToast({ message: '已加载示例图片' });

      } catch (resourceError) {
        console.error(`加载资源失败: ${JSON.stringify(resourceError)}`);

        // 尝试使用绝对路径
        console.info('尝试使用绝对路径加载图片');
        const absolutePath = 'D:/collegelife/Grade_three_second/SWE/frontend/entry/src/main/resources/rawfile/sample_artifact.jpg';

        try {
          // 使用文件IO API读取图片 - 修复返回值类型问题
          const file = await fs.open(absolutePath, fs.OpenMode.READ_ONLY);
          const fileInfo = await fs.stat(absolutePath);

          // 创建一个缓冲区，用于存放读取的数据
          const imageBuffer = new ArrayBuffer(fileInfo.size);

          // 读取数据到缓冲区中，read返回的是读取的字节数
          const bytesRead = await fs.read(file.fd, imageBuffer);
          await fs.close(file.fd);

          console.info(`成功读取样本图片, 大小: ${imageBuffer.byteLength} 字节，实际读取: ${bytesRead} 字节`);

          // 检查头部
          const dataView = new Uint8Array(imageBuffer);
          if (dataView[0] === 0xFF && dataView[1] === 0xD8) {
            console.info('验证成功: 正确的JPEG头部');
          }

          // 创建Buffer
          this.selectedImageData = buffer.from(imageBuffer);
          this.selectedImage = 'sample_artifact.jpg';
          this.searchButtonDisabled = false;

        } catch (fileError) {
          console.error(`文件读取失败: ${JSON.stringify(fileError)}`);
          throw new Error('无法加载样本图片');
        }
      }

    } catch (finalError) {
      console.error(`样本图片加载失败: ${JSON.stringify(finalError)}`);
      this.errorMsg = '加载样本图片失败';
      this.searchButtonDisabled = true;
    } finally {
      this.isLoading = false;
    }
  }

  // 创建图像预览
  async createImagePreview(imageData: buffer.Buffer) {
    try {
      // 释放旧的预览图片
      if (this.previewImage) {
        this.previewImage.release();
        this.previewImage = null;
      }

      // 创建图像源
      const imageSource = image.createImageSource(imageData.buffer);
      if (!imageSource) {
        throw new Error('创建图像源失败');
      }

      console.info('成功创建图像源，准备生成预览...');

      // 设置解码选项 - 添加明确的类型，更合适的尺寸
      const decodingOptions: image.DecodingOptions = {
        desiredSize: { width: 400, height: 400 }, // 减小尺寸，提高性能
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888 // 明确设置像素格式
      };

      // 创建像素图
      this.previewImage = await imageSource.createPixelMap(decodingOptions);

      // 释放图像源
      imageSource.release();

      if (!this.previewImage) {
        throw new Error('创建预览图像失败，结果为null');
      }

      // 直接检查图像尺寸，确认预览有效
      const imageInfo = await this.previewImage.getImageInfo();
      console.info(`预览图像创建成功，尺寸: ${imageInfo.size.width}x${imageInfo.size.height}`);

      this.isPreviewReady = true;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error);
      console.error(`创建图像预览失败: ${errorMsg}`);
      this.isPreviewReady = false;
      this.previewImage = null;
    }
  }

  // 从PixelMap获取图像数据
  async getPixelMapData(pixelMap: image.PixelMap): Promise<ArrayBuffer> {
    return new Promise<ArrayBuffer>((resolve, reject) => {
      try {
        // 创建图片包装器实例
        const imagePackerApi = image.createImagePacker();

        // 打包参数 - 添加明确的类型并降低质量以减小大小
        const packOptions: image.PackingOption = {
          format: 'image/jpeg',
          quality: 80 // 降低质量，确保数据大小合理
        };

        // 打包图像
        imagePackerApi.packing(pixelMap, packOptions)
          .then((data: ArrayBuffer) => {
            // 检查数据有效性
            if (!data || data.byteLength === 0) {
              imagePackerApi.release();
              reject(new Error("打包图像返回空数据"));
              return;
            }

            // 释放资源
            imagePackerApi.release();
            resolve(data);
          })
          .catch((err: Error) => {
            // 释放资源
            imagePackerApi.release();
            reject(err);
          });
      } catch (error) {
        reject(error instanceof Error ? error : new Error(String(error)));
      }
    });
  }

  // 开始图像搜索
  async startImageSearch() {
    if (!this.selectedImageData || this.searchButtonDisabled) {
      promptAction.showToast({ message: '请先选择图片' });
      return;
    }

    try {
      this.isLoading = true;
      this.errorMsg = '';
      this.showResults = false;

      // 发送图片数据到后端
      await this.sendImageToBackend(this.selectedImageData);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error);
      this.errorMsg = `图片处理失败: ${errorMsg}`;
      console.error(`图像搜索失败: ${errorMsg}`);
    } finally {
      this.isLoading = false;
    }
  }

  // 发送图片到后端进行以图搜图 - 修改为支持任何图像格式
  async sendImageToBackend(imageData: buffer.Buffer) {
    try {
      const url = ApiConstants.getFullUrl(ApiConstants.API_IMAGE_SEARCH);
      console.info(`准备发送图像搜索请求:`);
      console.info(`- URL: ${url}`);
      console.info(`- 图片数据大小: ${imageData.length} 字节`);
      console.info(`- Content-Type: image/jpeg`); 

      // 设置请求选项
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'image/jpeg',
          'Accept': 'application/json'
        },
        extraData: imageData.buffer,
        connectTimeout: 30000,
        readTimeout: 30000
      };

      console.info('发送HTTP请求中...');
      const response = await this.httpRequest.request(url, requestOptions);
      console.info(`收到响应，状态码: ${response.responseCode}`);

      // 处理响应
      if (response.responseCode === 200) {
        const resultStr = response.result ? response.result.toString() : '{}';
        console.info(`完整响应数据: ${resultStr}`); // 记录完整响应以便调试

        try {
          const result: ApiResponse = JSON.parse(resultStr);

          if (result.success && Array.isArray(result.data)) {
            console.info(`成功解析搜索结果，数据长度: ${result.data.length}`);
            
            // 确保清除旧的结果
            this.searchResults = [];

            // 设置新的搜索结果
            this.searchResults = result.data;
            
            // 确保显示结果标志被设置
            this.showResults = true;
            this.hasResults = this.searchResults.length > 0;
            
            console.info(`搜索返回了 ${this.searchResults.length} 个结果，结果将显示: ${this.showResults}`);
            
            // 强制UI更新
            this.isLoading = false;
            
            // 告知用户搜索完成
            promptAction.showToast({ 
              message: `找到 ${this.searchResults.length} 个相似文物`, 
              duration: 3000 
            });
          } else {
            this.errorMsg = result.message || '搜索未返回有效结果';
            console.error(`搜索失败: ${this.errorMsg}`);
            this.showResults = false;
            promptAction.showToast({ message: '搜索结果为空', duration: 3000 });
          }
        } catch (parseError) {
          console.error(`解析响应数据失败: ${parseError instanceof Error ? parseError.message : String(parseError)}`);
          console.error(`原始响应数据: ${resultStr.substring(0, 100)}...`);
          this.errorMsg = '解析搜索结果失败，请检查后端返回格式';
          this.showResults = false;
        }
      } else {
        this.errorMsg = `请求失败，状态码: ${response.responseCode}`;
        console.error(this.errorMsg);
        this.showResults = false;

        if (response.result) {
          try {
            const errorStr = response.result.toString();
            console.error(`错误详情: ${errorStr}`);

            const errorObj: ErrorResponse = JSON.parse(errorStr);
            if (errorObj.message) {
              this.errorMsg += `\n${errorObj.message}`;
            }
          } catch (e) {
            // 解析错误响应失败，忽略
          }
        }
      }
    } catch (error) { 
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error);
      this.errorMsg = `请求过程中发生错误: ${errorMsg}`;
      console.error(`HTTP请求失败: ${errorMsg}`);
      this.showResults = false;
    }
  }

  // 检查API端点是否可用
  async checkApiEndpoint() {
    try {
      const url = ApiConstants.getFullUrl(ApiConstants.API_HEALTH_CHECK);
      console.info(`检查API健康状态: ${url}`);

      // 显示正在连接的URL，帮助调试
      promptAction.showToast({ message: `正在连接: ${url}` });

      const response: http.HttpResponse = await this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: { 'Accept': 'application/json' },
          connectTimeout: 5000,
          readTimeout: 5000
        }
      );

      if (response.responseCode >= 200 && response.responseCode < 300) {
        promptAction.showToast({ message: 'API服务器连接正常' });
        return true;
      } else {
        promptAction.showToast({ message: `API服务器返回异常状态: ${response.responseCode}` });
        return false;
      }
    } catch (error) { // 添加明确类型
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`API健康检查失败: ${errorMsg}`);

      // 显示详细错误信息
      promptAction.showToast({
        message: `连接失败: ${errorMsg.substring(0, 50)}...`,
        duration: 5000
      });
      return false;
    }
  }


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


  // 在UI构建函数中添加更多调试信息
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('←')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .height(40)
        .width(40)
        .backgroundColor('transparent')
        .onClick(() => {
          router.back();
        })

        Text('以图搜图')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({left: 16, right: 16})
      .backgroundColor('#FFFFFF')

      // 主内容区域
      Scroll() {
        Column() {
          // 说明文本
          Text('以图搜图 - 查找相似文物')
            .fontSize(16)
            .margin({top: 20, bottom: 16})
            .textAlign(TextAlign.Center)

          // 图片选择区域
          Column() {
            Text('选择图片')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({bottom: 12})

            // 图片操作按钮
            Row() {
              Button({ type: ButtonType.Normal }) {
                Row() {
                  Text('上传本地图片')
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                }
              }
              .height(40)
              .backgroundColor('#3366FF')
              .borderRadius(20)
              .layoutWeight(1)
              .onClick(() => {
                this.selectImageWithPhotoHelper();
              })

                                          /* 注释掉示例图片按钮              Button({ type: ButtonType.Normal }) {                Row() {                  Text('使用示例图片')                    .fontSize(14)                    .fontColor('#FFFFFF')                }              }              .height(40)              .margin({ left: 12 })              .backgroundColor('#4CAF50')              .borderRadius(20)              .layoutWeight(1)              .onClick(() => {                this.useSampleImage();              })              */
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 改进的图片预览区域 - 添加调试信息
            Column() {
              // 添加调试信息
              Text(`预览状态: ${this.isPreviewReady ? "准备好" : "未准备"}, 图像对象: ${this.previewImage ? "已创建" : "未创建"}`)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ bottom: 8 })

              if (this.isPreviewReady && this.previewImage) {
                Text('预览图片')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 8 })

                // 改进的图片显示
                Stack({ alignContent: Alignment.Center }) {
                  // 背景
                  Column()
                    .width('100%')
                    .height('100%')
                    .aspectRatio(1)
                    .backgroundColor('#EEEEEE')

                  // 边框标记，确保容器显示
                  Column()
                    .width('99%')
                    .height('99%')
                    .borderWidth(2)
                    .borderColor('#FF9800')

                  // 图片 - 使用高对比度背景
                  Column() {
                    Image(this.previewImage)
                      .width('90%')
                      .height('90%')
                      .objectFit(ImageFit.Cover)
                      .backgroundColor('#333333')
                      .borderRadius(4)
                      .onComplete(() => {
                        console.info('图片渲染完成');
                      })
                      .onError(() => {
                        console.error('图片加载失败');
                        this.errorMsg = '图片预览加载失败';
                      })
                  }
                  .width('95%')
                  .height('95%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor('#DDDDDD')
                }
                .width('100%')
                .aspectRatio(1)
                .margin({ bottom: 16 })
              } else if (this.isLoading) {
                LoadingProgress()
                  .width(50)
                  .height(50)
                  .color('#3366FF')
                  .margin({ top: 30, bottom: 30 })
              } else {
                Text('请选择一张图片')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 40, bottom: 40 })
              }
            }
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(16)
            .alignItems(HorizontalAlign.Center)

            // 搜索按钮
            Button('开始搜索')
              .width('100%')
              .height(44)
              .margin({ top: 16 })
              .backgroundColor(this.searchButtonDisabled ? '#CCCCCC' : '#FF9800')
              .borderRadius(22)
              .enabled(!this.searchButtonDisabled)
              .onClick(() => {
                this.startImageSearch();
              })

          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({bottom: 16})

          // 加载状态或错误提示
          if (this.isLoading) {
            Row() {
              LoadingProgress()
                .width(24)
                .height(24)
                .color('#3366FF')

              Text('搜索中...')
                .fontSize(16)
                .margin({left: 8})
            }
            .margin({top: 16, bottom: 16})
          }

          if (this.errorMsg.length > 0) {
            Text(this.errorMsg)
              .fontSize(14)
              .fontColor('#FF0000')
              .width('90%')
              .margin({top: 16, bottom: 16})
              .padding(12)
              .backgroundColor('#FFEBEE')
              .borderRadius(8)
          }

          // 搜索结果部分改进
          if (this.showResults) {
            Column() {
              Text('搜索结果')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)
                .margin({bottom: 16})

              if (this.searchResults.length > 0) {
                Text(`找到 ${this.searchResults.length} 个相似文物`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({bottom: 12})
                  
                // 添加调试信息以检查结果
                Text(`调试: 显示 ${this.searchResults.length} 个结果`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .alignSelf(ItemAlign.Start)
                  .margin({bottom: 8})
                  
                ForEach(this.searchResults, (item: Artifact) => {
                  // 打印每个文物项以便调试
                  // console.info(`渲染文物项: ID=${item.id}, 名称=${item.name}`);
                  
                  ArtifactItem({
                    artifact: item,
                    onItemClick: (artifact: Artifact) => {
                      this.navigateToDetail(artifact);
                    }
                  })
                })
              } else {
                Column() {
                  Text('📷')
                    .fontSize(50)
                    .fontColor('#CCCCCC')
                    .margin({top: 40, bottom: 20})

                  Text('未找到相似文物')
                    .fontSize(16)
                    .fontColor('#999999')
                    .margin({bottom: 40})
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
            }
            .width('100%')
            .padding({left: 16, right: 16, bottom: 20})
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }

  // 测试备用图像搜索端点
  async testAlternativeImageSearch() {
    // 确保有图像数据
    if (!this.selectedImageData) {
      await this.useSampleImage();
    }

    try {
      this.isLoading = true;
      this.errorMsg = '';
      this.showResults = false;

      // 再次验证非空
      if (!this.selectedImageData) {
        throw new Error("无法创建图像数据");
      }

      const url = ApiConstants.getFullUrl(ApiConstants.API_IMAGE_SEARCH_ALT); // 使用常量中定义的备用端点
      console.info(`测试备用端点: ${url}`);

      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'image/jpeg',
          'Accept': 'application/json'
        },
        // 修复类型问题：使用.buffer属性获取ArrayBuffer
        extraData: this.selectedImageData.buffer, // 修复类型错误
        connectTimeout: 30000,
        readTimeout: 30000
      };

      const response = await this.httpRequest.request(url, requestOptions);
      console.info(`备用端点测试响应，状态码: ${response.responseCode}`);

      if (response.responseCode === 200) {
        promptAction.showToast({ message: '备用端点测试成功!' });
        // 处理结果
        const resultStr = response.result ? response.result.toString() : '{}';
        const result: ApiResponse = JSON.parse(resultStr);

        if (result.success && Array.isArray(result.data)) {
          this.searchResults = result.data;
          this.showResults = true;
        }
      } else {
        this.errorMsg = `备用端点请求失败，状态码: ${response.responseCode}`;
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error);
      this.errorMsg = `备用端点测试失败: ${errorMsg}`;
    } finally {
      this.isLoading = false;
    }
  }
}
