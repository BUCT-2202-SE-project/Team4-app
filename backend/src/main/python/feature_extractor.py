import os
import sys
import logging
import traceback
import torch
import numpy as np
from torchvision import models, transforms
from PIL import Image
import json
from flask import Flask, request, jsonify

# 配置日志
logging.basicConfig(
    level=logging.DEBUG,  # 修改为DEBUG级别以获取更多信息
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("feature_extractor.log", encoding='utf-8'),  # 添加编码
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("feature-extractor")

# 检查依赖
logger.info("Checking dependencies...")
try:
    import torch
    logger.info(f"PyTorch version: {torch.__version__}")
    import torchvision
    logger.info(f"TorchVision version: {torchvision.__version__}")
    from PIL import Image, __version__ as pil_version
    logger.info(f"Pillow version: {pil_version}")
    import numpy as np
    logger.info(f"NumPy version: {np.__version__}")
    import flask
    logger.info(f"Flask version: {flask.__version__}")
except ImportError as e:
    logger.error(f"Missing dependency: {e}")
    logger.error("Please run: pip install -r requirements.txt")
    sys.exit(1)

app = Flask(__name__)

# 全局变量，用于存储模型
model = None  # 去掉global声明，避免作用域问题

# 自定义JSON编码器，确保numpy类型正确序列化
class NumpyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        if isinstance(obj, np.float32) or isinstance(obj, np.float64):
            return float(obj)
        return json.JSONEncoder.default(self, obj)

def load_model():
    """加载ResNet50模型，仅在需要时初始化"""
    global model
    if model is None:
        logger.info("Loading ResNet50 model...")
        try:
            # 加载ResNet50（移除最后一层）
            model_temp = models.resnet50(weights=models.ResNet50_Weights.IMAGENET1K_V1)
            
            # 检查模型参数类型，在模型加载阶段确保是double类型
            logger.debug(f"原始模型参数类型: {next(model_temp.parameters()).dtype}")
            
            # 强制模型参数为double (float64)类型
            model_temp = model_temp.double()
            logger.info(f"转换后模型参数类型: {next(model_temp.parameters()).dtype}")
                
            model = torch.nn.Sequential(*list(model_temp.children())[:-1])
            model.eval()
            
            # 再次验证模型状态
            model_dtype = next(model.parameters()).dtype
            logger.info(f"最终模型参数类型: {model_dtype}, 确认是torch.float64: {model_dtype == torch.float64}")
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            logger.error(traceback.format_exc())
            raise RuntimeError(f"Failed to load ResNet50 model: {str(e)}")

# 图像预处理
preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

def extract_features(image_path):
    """提取图像特征向量"""
    # 确保模型已加载
    load_model()
    
    # 确保numpy已导入到当前作用域
    import numpy as np
    
    # 检查文件存在
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Image file not found: {image_path}")
    
    try:
        logger.info(f"Processing image: {image_path}")
        
        # 检查文件大小
        file_size = os.path.getsize(image_path)
        logger.info(f"Image file size: {file_size} bytes")
        
        if file_size == 0:
            raise ValueError("Image file is empty")
            
        # 检查文件头部，确保是JPEG格式
        with open(image_path, 'rb') as f:
            header = f.read(10)
            hex_header = ' '.join(f"{b:02X}" for b in header)
            logger.info(f"File header (hex): {hex_header}")
            
            if not (header[0] == 0xFF and header[1] == 0xD8):
                logger.warning("File doesn't have JPEG header markers (FF D8)")
        
        try:
            # 打开并预处理图像 - 使用更健壮的方式
            image = Image.open(image_path).convert("RGB")
            logger.info(f"Image opened successfully - Size: {image.size}, Mode: {image.mode}")
            
            # 转换为双精度类型的输入 - 验证类型转换是否成功
            input_tensor = preprocess(image).unsqueeze(0)
            logger.debug(f"处理前输入张量类型: {input_tensor.dtype}")
            
            # 确保输入是double类型
            input_tensor = input_tensor.double()
            logger.info(f"处理后输入张量类型: {input_tensor.dtype}, 是否为double: {input_tensor.dtype == torch.float64}")
            
            # 提取特征前记录模型参数类型
            model_dtype = next(model.parameters()).dtype
            logger.info(f"预测前模型参数类型: {model_dtype}")
            
            # 提取特征
            with torch.no_grad():
                features = model(input_tensor)
                logger.info(f"原始输出特征类型: {features.dtype}")
                
                # 强制转换为double类型
                if features.dtype != torch.float64:
                    features = features.double()
                    logger.info(f"转换后输出特征类型: {features.dtype}")
                    
                features = features.squeeze().cpu().numpy()
            
            # 记录特征类型和形状
            logger.info(f"[Python] 特征数据类型: {features.dtype} | numpy类型: {type(features)}")
            
            # L2归一化（余弦相似度优化）
            features = features / np.linalg.norm(features)
            
            # 显式检查numpy数组的dtype是否为float64
            if features.dtype != np.float64:
                logger.warning(f"特征数据类型不是float64，正在转换: {features.dtype} -> float64")
                features = features.astype(np.float64)
            
            logger.info(f"[Python] 特征数据类型: {features.dtype} | numpy类型: {type(features)}")
            
            # 明确转换为float64 (double)类型
            features_double = features.astype(np.float64)
            logger.info(f"Converted features to double - shape: {features_double.shape}, dtype: {features_double.dtype}")
            
            # 检查第一个元素确认类型
            if len(features_double) > 0:
                first_elem = features_double[0]
                logger.info(f"[Python] 首元素类型: {type(first_elem)} | 值: {first_elem}")
            
            return features_double
        except Exception as e:
            logger.error(f"Error in PIL/Torch processing: {e}")
            logger.error(traceback.format_exc())
            
            # 尝试备用方法
            logger.info("Trying alternative method with OpenCV")
            import cv2
            
            # 使用OpenCV读取图像
            img = cv2.imread(image_path)
            if img is None:
                raise ValueError("OpenCV could not read the image file")
                
            logger.info(f"Image loaded with OpenCV - Shape: {img.shape}")
            
            # OpenCV读取的是BGR，需要转换为RGB
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            
            # 调整大小为ResNet输入尺寸
            img = cv2.resize(img, (224, 224))
            
            # 转换为双精度浮点数
            img = img.astype(np.float64) / 255.0
            img = (img - np.array([0.485, 0.456, 0.406], dtype=np.float64)) / np.array([0.229, 0.224, 0.225], dtype=np.float64)
            img = img.transpose((2, 0, 1))  # (H,W,C) -> (C,H,W)
            img = np.expand_dims(img, axis=0)  # 添加batch维度
            
            input_tensor = torch.from_numpy(img).double()  # 确保使用double
            logger.info(f"Alternative input tensor dtype: {input_tensor.dtype}")
            
            # 提取特征
            with torch.no_grad():
                features = model(input_tensor)
                logger.info(f"Alternative raw feature tensor dtype: {features.dtype}")
                features = features.squeeze().cpu().numpy()
                
            # L2归一化
            features = features / np.linalg.norm(features)
            
            # 确保是double类型
            features_double = features.astype(np.float64)
            logger.info(f"Alternative feature extraction successful - shape: {features_double.shape}, dtype: {features_double.dtype}")
            
            return features_double
            
    except Exception as e:
        logger.error(f"Feature extraction failed: {e}")
        logger.error(traceback.format_exc())
        raise

@app.route('/extract', methods=['POST'])
def extract():
    """API端点：提取图像特征"""
    logger.info("Received feature extraction request")
    
    try:
        # 验证请求格式
        if not request.is_json:
            logger.error("Invalid request: Not JSON")
            return jsonify({'error': '请求必须是JSON格式'}), 400
            
        if 'image_path' not in request.json:
            logger.error("Invalid request: Missing image_path")
            return jsonify({'error': '未提供图像路径'}), 400
            
        image_path = request.json['image_path']
        logger.info(f"Extracting features for image: {image_path}")
        
        # 提取特征
        features_array = extract_features(image_path)
        
        # 确认数据类型并记录详细的调试信息
        logger.info(f"Features array type before conversion: {type(features_array).__name__}")
        logger.info(f"Features array dtype: {features_array.dtype}")
        
        # 检查第一个特征值的具体类型
        if len(features_array) > 0:
            first_item = features_array[0]
            logger.info(f"[Python] 序列化前：首元素类型: {type(first_item)} | 值: {first_item}")
        
        # 更彻底的类型转换 - 不使用numpy.tolist()，改用手动转换为Python内置float
        try:
            features_list = [float(x) for x in features_array]
            logger.info(f"手动转换为内置float成功，长度: {len(features_list)}")
            if features_list:
                logger.info(f"手动转换后首元素类型: {type(features_list[0]).__name__}, 值: {features_list[0]}")
        except Exception as e:
            logger.error(f"手动转换为内置float失败: {e}")
            # 非常保守的备选方案
            features_list = []
            for x in features_array:
                try:
                    # 使用字符串中转，确保类型转换
                    features_list.append(float(str(x)))
                except Exception as inner_e:
                    logger.error(f"转换元素 {x} 失败: {inner_e}")
                    features_list.append(0.0)  # 使用默认值
        
        # 使用字符串格式化
        feature_values = [f"{float(x):.16f}" for x in features_list]
        
        # 确保返回时不使用numpy特定类型
        response_data = {
            'success': True,
            'featureValues': feature_values
        }
        
        # 检查并记录最终响应数据类型
        if feature_values and len(feature_values) > 0:
            logger.info(f"[Python] 最终响应首元素: 类型={type(feature_values[0]).__name__}, 值={feature_values[0]}")
            
        # 使用标准JSON序列化，不使用custom encoder
        return jsonify(response_data)

    except FileNotFoundError as e:
        logger.error(f"File not found: {str(e)}")
        return jsonify({
            'success': False,
            'error': f"文件不存在: {str(e)}"
        }), 404
    except Exception as e:
        logger.error(f"Error during feature extraction: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({
            'success': False,
            'error': f"特征提取失败: {str(e)}"
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """健康检查端点"""
    return jsonify({'status': 'ok', 'message': 'Service is running'})

if __name__ == '__main__':
    logger.info("Starting feature extraction service...")
    # 预加载模型
    try:
        load_model()
        logger.info("Model pre-loaded successfully")
    except Exception as e:
        logger.error(f"Model pre-loading failed: {e}")
    
    # 启动Flask服务
    app.run(host='localhost', port=5000, debug=False)
    logger.info("Service started on http://localhost:5000")
