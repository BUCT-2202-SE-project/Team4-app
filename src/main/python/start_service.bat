@echo off
echo 启动特征提取服务...
cd /d %~dp0
python -m pip install -r requirements.txt
python feature_extractor.py
pause
