# Forlove Keyboard

一个商业级第三方 iOS 输入法系统，帮助用户生成高质量的聊天回复。

## 🎯 核心功能 V2（矩阵结构）

### 6 大主分类

| 分类 | 说明 | 子分类 |
|------|------|--------|
| **帮你回** | 针对对方发来的消息进行针对性回复 | 高情商、暧昧、撩拨、礼貌、夸捧 |
| **帮开场** | 主动发起有吸引力的开场对话 | 幽默破冰、好奇提问、朋友圈切入、直球进击 |
| **帮润色** | 将表达优化得更加得体有情商 | 职场精英、去油腻、更有文采、简洁有力 |
| **夸捧模式** | 纯粹的情绪价值输出 | 细节夸、花式彩虹屁、侧面仰慕 |
| **法律专家** | 用通俗易懂的方式解读法律问题 | 深入浅出、大概讲解、避坑指南、模拟判例 |
| **生活百科** | 解答各类知识问题并提供实用建议 | 大概讲解、核心步骤、辟谣专家、购物建议 |

### 用户可配置项
- 用户可以为每个主分类选择子分类
- 用户可以自定义风格参数（暧昧等级、表情密度、字数长度）
- 用户选择 3 个激活分类在输入法中使用

## 🏗 工程结构

```
ForloveKeyboard/
├── ForloveHostApp/                    # 主 App
│   ├── AppDelegate.swift
│   ├── Scenes/
│   │   ├── Onboarding/               # 引导流程
│   │   │   ├── OnboardingViewController.swift
│   │   │   └── PermissionGuideViewController.swift
│   │   ├── Home/                     # 首页
│   │   │   ├── HomeViewController.swift
│   │   │   └── KeyboardStatusCardView.swift
│   │   ├── Identity/                 # 身份设置
│   │   │   └── IdentitySettingsViewController.swift
│   │   ├── Style/                    # 风格偏好
│   │   │   └── StyleSettingsViewController.swift
│   │   └── SlotConfiguration/        # 槽位配置（新增）
│   │       └── SlotConfigurationViewController.swift
│   ├── Services/
│   │   ├── PermissionService.swift
│   │   └── SettingsService.swift
│   ├── Info.plist
│   └── ForloveHostApp.entitlements
│
├── ForloveKeyboardExtension/          # 键盘扩展
│   ├── KeyboardViewController.swift   # 主控制器
│   ├── Views/
│   │   ├── KeyboardRootView.swift
│   │   ├── TopActionBarView.swift
│   │   ├── SceneTabsView.swift
│   │   ├── SlotTabsView.swift        # 槽位标签栏（新增）
│   │   ├── QuickToolsRowView.swift
│   │   ├── CandidateListView.swift
│   │   ├── CandidateCardView.swift
│   │   ├── CompactCandidateCardView.swift  # 紧凑候选卡片（新增）
│   │   ├── PolishCompareView.swift
│   │   └── EmptyStateView.swift
│   ├── State/
│   │   └── KeyboardState.swift       # 支持槽位系统
│   ├── Services/
│   │   ├── SharedSettingsReader.swift
│   │   ├── ClipboardService.swift
│   │   ├── FullAccessChecker.swift
│   │   └── ExtensionNetworkClient.swift  # 支持槽位 API
│   ├── Info.plist
│   └── ForloveKeyboardExtension.entitlements
│
├── SharedKit/                         # 共享模块
│   ├── Models/
│   │   ├── UserIdentity.swift
│   │   ├── StyleProfile.swift
│   │   ├── GenSpec.swift
│   │   ├── Candidate.swift
│   │   └── CategorySlot.swift        # 分类槽位模型（新增）
│   ├── Storage/
│   │   ├── AppGroupStore.swift       # 支持槽位存储
│   │   └── Keys.swift
│   ├── Prompting/
│   │   ├── PromptTemplates.swift
│   │   ├── PromptBuilder.swift
│   │   ├── PromptEngine.swift        # 统一提示词引擎（新增）
│   │   └── SafetyRules.swift
│   ├── Utils/
│   │   ├── TextUtils.swift
│   │   └── Debounce.swift
│   └── Config/
│       ├── FeatureFlags.swift
│       └── DesignSystem.swift
│
└── Server/                            # 服务端 PHP
    ├── config.php
    ├── generate.php                   # 支持 6 大分类
    ├── prompts.php                    # 矩阵结构提示词
    └── README.md
```

## 🎨 设计规范

遵循「轻黑金视觉规范 v1.0」：

### 色彩系统
- **主金色**: `#C8A46A` - 偏暖、低饱和
- **背景色**: `#F7F6F4` - 暖灰白
- **卡片**: `#FFFFFF` - 纯白
- **主文字**: `#1F1F1F`
- **次要文字**: `#6F6F6F`

### 设计原则
- 金色 ≤ 10% 屏幕面积
- 不使用纯黑背景
- 不做满屏渐变
- 圆角卡片、胶囊按钮、轻阴影
- 动效克制（150ms ease-out）

## 📱 核心体验 V2

### 矩阵结构（新）
用户在主 App 中配置 6 大分类：
1. 为每个分类选择一个子分类
2. 可自定义风格参数（暧昧等级、表情密度、字数）
3. 选择 3 个分类激活在输入法中使用

### 提示词生成引擎
统一的提示词拼装公式：
```
Identity + Main_Category_Task + Sub_Category_Style + Global_Constraints
```

### 候选展示（新）
- 返回 3 个回复选项
- 第 1 项直接填充到输入区
- 第 2、3 项展示前 30 字预览
- 选择第 2/3 项时替换输入区内容

### iOS 限制处理
- 无法读取第三方 App 聊天内容
- 剪贴板需用户主动点击才读取
- 网络请求需开启"允许完全访问"
- 提供离线模板作为降级方案

### 铁律
1. 任何生成行为必须由用户明确操作触发
2. 按钮即意图，不自行扩展用户意图
3. 输出必须是"可直接使用的文本"
4. 不输出解释、建议、分析、AI 相关内容
5. 只做文本插入，不模拟点击"发送"按钮

## 🔧 配置要求

### App Group
配置标识符：`group.com.forlove.keyboard`

### Bundle Identifiers
- 主 App: `com.forlove.keyboard`
- 键盘扩展: `com.forlove.keyboard.keyboardextension`

### 服务端部署
- 部署 `Server/` 目录下的 PHP 文件到阿里云服务器
- 在 `config.php` 中配置 DeepSeek API Key
- API 地址：`https://aiin.bytepig.xyz/generate.php`

## 🚀 开发指南

### 1. 创建 Xcode 项目
使用 XcodeGen 生成项目：
```bash
cd ForloveKeyboard
xcodegen generate
open ForloveKeyboard.xcodeproj
```

### 2. Target 配置
- ForloveHostApp: 添加所有 HostApp 和 SharedKit 文件
- ForloveKeyboardExtension: 添加所有 Extension 和 SharedKit 文件

### 3. 运行测试
1. 运行主 App，完成引导流程
2. 配置分类槽位（选择 3 个激活分类）
3. 在设置中启用 Forlove 键盘
4. 开启"允许完全访问"
5. 在任意 App 中切换到 Forlove 键盘测试

## 📝 更新日志

### V2.0 - 矩阵结构改进
- ✅ 新增 `CategorySlot` 分类槽位模型
- ✅ 支持 6 大主分类和各自的子分类
- ✅ 新增 `PromptEngine` 统一提示词生成引擎
- ✅ 主 App 新增"分类配置"页面
- ✅ 键盘扩展支持槽位切换
- ✅ 服务端 PHP 支持新的分类结构
- ✅ 候选展示优化（第 1 项填充，第 2/3 项预览）

### V1.0 - 初始版本
- ✅ 帮你回/帮开场/帮润色三大模式
- ✅ 身份设置和风格偏好
- ✅ 轻黑金视觉规范
- ✅ App Group 数据共享
- ✅ 服务端 PHP 中转 DeepSeek API

## 📄 License

Private - All Rights Reserved
