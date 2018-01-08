@echo off

rem * 端口映射管理中心
rem * 启动脚本
rem *

rem 设置终端编码(代码页), 65001:UTF-8, 936:GBK
chcp 936

rem 在这里启动服务开始
echo "************************"
echo "**  端口映射管理中心  **"
echo "************************"
echo "服务正在启动！！！"
C:\MapManager\runVM\Scripts\python.exe C:\MapManager\managerDebug.py

rem 下面将停止服务
echo "服务已停止！！！"

rem 设置暂停
pause