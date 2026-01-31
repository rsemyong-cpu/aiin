# Forlove Keyboard V5 更新日志

## 概述

V5 版本主要实现了输入法端按钮功能的优化和交互逻辑的改进。

---

## 核心修改

### 1. 顶部操作栏按钮重构 (`TopActionBarView.swift`)

**修改前：**
- 右侧三个按钮：`3`（候选数量切换）、`切`（替换）、`⋯`（更多）

**修改后：**
- 右侧两个按钮：
  - `切换` - 点击后在备选展示区交替展现备选2和备选3的内容
  - `选中` - 点击后选中当前展示的备选内容，录入到输入区，替换首选内容
- 删除了 `⋯`（更多）按钮

### 2. 中间区域改为备选展示区 (`KeyboardRootView.swift`)

**修改前：**
- 中间区域为"粘贴区卡片"，左侧显示完整输入内容

**修改后：**
- 中间区域改为"备选展示区"
- 左侧显示当前备选内容的前30字符预览
- 右侧保留粘贴按钮
- 支持切换显示备选2或备选3

### 3. 交互逻辑优化 (`KeyboardViewController.swift`)

**新的完整交互流程：**

1. **粘贴剪贴板** - 点击右侧"粘贴"按钮读取剪贴板内容
2. **选择二级主题** - 点击九宫格中的二级分类，触发 API 请求
3. **API 返回三条回复** - 
   - 首选内容（第1条）直接录入到输入区
   - 备选2（第2条）展示在备选展示区（前30字符预览）
4. **切换备选** - 点击"切换"按钮，在备选2和备选3之间切换展示
5. **选中备选** - 点击"选中"按钮，用当前展示的备选内容替换首选，录入到输入区
6. **发送** - 点击右侧工具栏"发送"按钮

---

## 文件修改列表

| 文件路径 | 操作 | 说明 |
|---------|------|------|
| `ForloveKeyboardExtension/Views/TopActionBarView.swift` | 重构 | 按钮改名、删除"更多"按钮 |
| `ForloveKeyboardExtension/Views/KeyboardRootView.swift` | 重构 | 改为备选展示区 |
| `ForloveKeyboardExtension/KeyboardViewController.swift` | 修改 | 更新交互逻辑 |

---

## 新增/修改的方法

### TopActionBarView
- `switchAlternateButton` - 切换备选展示按钮（原 candidateCountButton）
- `selectAlternateButton` - 选中备选内容按钮（原 replaceButton）
- `switchAlternateTapped()` - 切换按钮点击事件
- `selectAlternateTapped()` - 选中按钮点击事件
- 删除了 `moreButton` 和 `moreTapped()`

### KeyboardRootView
- `alternateContainer` - 备选展示区卡片（原 inputContainer）
- `alternateLabel` - 备选内容标签（原 inputLabel）
- `allCandidates` - 存储所有候选内容
- `currentAlternateDisplayIndex` - 当前展示的备选索引
- `updateAlternateDisplay()` - 更新备选展示区内容
- `switchAlternateDisplay()` - 切换备选展示
- `getCurrentAlternateText()` - 获取当前展示的备选内容
- `clearAlternates()` - 清空备选展示

### KeyboardViewController
- 修改 `didTapPaste()` - 不再自动生成，提示用户点击二级主题
- 修改 `didTapClear()` - 调用 `clearAlternates()`
- 修改 `didToggleCandidateCount()` - 调用 `switchAlternateDisplay()`
- 修改 `didReplaceWithAlternate()` - 使用 `getCurrentAlternateText()` 获取备选内容
- 修改 `handleCandidatesReceived()` - 首选直接录入，更新备选展示区

---

## 设计决策

1. **备选展示区只显示前30字符** - 避免遮挡其他UI元素，用户可通过"选中"查看完整内容
2. **删除"更多"按钮** - 简化界面，减少用户认知负担
3. **粘贴后不自动生成** - 需先粘贴，再点击二级主题，确保用户明确意图
4. **每次切换二级主题都提交API** - 根据用户需求，每次选择二级分类都触发新的生成请求

---

## 主 App 分类系统重构

### 1. 分类结构调整 (`CategorySlot.swift`)

**修改为固定的5个主分类：**

| 主分类 | 二级分类数量 | 二级分类列表 |
|-------|------------|-------------|
| 帮你回 (Reply) | 9个 | 高情商、暧昧、撩拨、礼貌、夸捧、高冷霸总、理性回应、幽默化解、怼人模式 |
| 帮开场 (Opening) | 6个 | 幽默破冰、好奇提问、朋友圈切入、直球进击、日常随聊、轻赞美开场 |
| 帮润色 (Polishing) | 8个 | 职场精英、去油腻、更有文采、简洁有力、更深情、更幽默、更正式、更随意 |
| 角色代入 (RolePlay) | 12个 | 律师、医生、程序员、会计、金牌销售、健身教练、心理咨询师、职场导师、产品经理、毒舌评审、哲学大师、情感教练 |
| 生活百科 (LifeWiki) | 6个 | 大概讲解、核心步骤、辟谣专家、购物建议、避坑指南、优劣对比 |

**删除的分类：**
- ~~夸捧模式~~ （合并到"帮你回"的二级分类中）
- ~~法律专家~~ （合并到"角色代入"的律师角度中）

### 2. 新增参数 (`SlotConfigV2`)

| 参数 | 选项 | 说明 |
|-----|------|------|
| 字数偏好 | 短/中/长 | 控制AI回复的长度 |
| 激进风险指数 | 低/中/高 | 低=保守安全，高=前卫敢说 |
| 成人风格 | 无/轻/重 | 无=不涉及，轻=暗示，重=放开但不色情 |

### 3. 配置页面简化 (`SlotEditViewControllerV2.swift`)

**修改前：**
- 可自定义主分类名称
- 可添加/删除二级分类（最多9个）
- 可输入身份设定
- 字数选择
- 激进程度选择

**修改后：**
- 主分类只读展示（固定不可修改）
- 二级分类只读展示（固定不可修改）
- 字数偏好选择（短/中/长）
- 激进风险指数选择（低/中/高）
- 成人风格选择（无/轻/重）

---

*此文件生成于 2026-01-30，由 Antigravity 协助完成。*
