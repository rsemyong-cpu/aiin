#!/bin/bash

# Forlove Keyboard 项目初始化脚本

echo "🚀 开始初始化 Forlove Keyboard 工程..."

# 1. 检查 XcodeGen 是否安装
if ! command -v xcodegen &> /dev/null
then
    echo "⚠️ 未找到 xcodegen，正在尝试通过 brew 安装..."
    brew install xcodegen
fi

# 2. 生成工程文件
echo "📦 正在生成 .xcodeproj 文件..."
xcodegen generate

# 3. 提示后续步骤
echo "✅ 工程生成成功！"
echo "👉 请双击打开 ForloveKeyboard.xcodeproj 开始开发。"
echo "💡 提示：在 Xcode 中运行前，请确保已在两个 Target 的 Signing & Capabilities 中配置了正确的 App Group。"
