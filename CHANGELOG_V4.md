# Forlove Keyboard V4 更新日志

## 概述

V4 版本主要实现了以下两大目标：

### 任务 1：输入法布局重构
根据用户需求重新设计键盘布局：
- **上边区域**：显示一级主题（如"帮你回"、"帮润色"），默认展示 3 个
- **九宫格区域**：二级分类九宫格展示（最多 9 个选项）
- **候选数量切换按钮**：顶部操作栏新增按钮，可切换显示 2 或 3 个候选
- **替换按钮**：可用备选内容替换首选内容

### 任务 2：主 App 配置结构改进
每个配置项改为：
- **主分类**：用户可自定义名称
- **N 个二级分类**：最多 9 个，用户可添加/删除
- **身份设置**：手动输入
- **字数多少**：少/中/多
- **风险激进程度**：低/中/高

---

## 核心文件修改

### SharedKit/Models/CategorySlot.swift

新增：
- `WordCount` 枚举：字数选项（少/中/多）
- `AggressionLevel` 枚举：表达激进程度（低/中/高）（注意：避免与 StyleProfile.RiskLevel 冲突）
- `CustomSubCategory` 结构体：用户自定义二级分类
- `SlotConfigV2` 结构体：增强版配置，包含：
  - `customMainName`: 自定义主分类名称
  - `customSubCategories`: 自定义二级分类列表
  - `identitySetting`: 身份设置
  - `wordCount`: 字数选择
  - `aggressionLevel`: 表达激进程度

扩展 `CategorySlot`：
- 新增 `configV2` 属性
- 新增 `selectedCustomSubIndex` 属性
- 新增 `displayName` 计算属性
- 新增 `currentSubCategoryName` 计算属性
- 新增 `allAvailableSubCategories` 方法
- 新增 `apiConfig` 方法

### SharedKit/Prompting/PromptEngine.swift

- 更新 `buildSubCategoryStyle()` 方法，支持 V2 配置
- 更新 `buildGlobalConstraints()` 方法，根据风险激进程度调整约束
- 修改 `buildSystemPrompt()` 以传递 slot 参数

### ForloveKeyboardExtension/Views/

#### 新增文件：SubCategoryGridView.swift
- 二级分类九宫格视图组件
- 支持展示系统预设 + 用户自定义的二级分类
- 点击选中、长按触发生成

#### TopActionBarView.swift
- 新增 `candidateCountButton`：候选数量切换按钮
- 新增 `replaceButton`：替换按钮
- 新增 `rightActionsStack`：右侧操作按钮容器
- 新增委托方法：`didTapToggleCandidateCount()` 和 `didTapReplaceWithAlternate()`

#### KeyboardRootView.swift
- 新增 `subCategoryGridView` 子视图
- 更新布局以显示九宫格
- 实现 `SubCategoryGridViewDelegate`
- 新增委托方法：`didToggleCandidateCount()`, `didReplaceWithAlternate()`, `didSelectSubCategory()`

#### CandidateListView.swift
- 新增 `displayCount` 属性
- 新增 `setDisplayCount()` 方法
- 更新 `rebuildCards()` 以支持可变数量的候选显示

### ForloveHostApp/Scenes/SlotConfiguration/

#### 新增文件：SlotEditViewControllerV2.swift
增强版槽位编辑页面，支持：
- 自定义主分类名称
- 二级分类管理（添加/删除/选择）
- 身份设置输入
- 字数选择（段落控制器）
- 风险激进程度选择

新增辅助类：
- `ConfigSectionView`：配置区域视图
- `SubCategoryEditCell`：二级分类编辑单元格
- `AddSubCategoryCell`：添加二级分类单元格

### Server/generate.php

- 升级到 V3
- 新增 V2 配置参数解析：
  - `word_count`: 字数选择
  - `risk_level`: 风险激进程度
  - `identity`: 身份设置
  - `custom_sub_name`: 自定义二级分类名称
  - `display_name`: 自定义主分类名称

### Server/prompts.php

- 更新 `buildSystemPrompt()` 方法
- 新增字数要求描述映射
- 新增风险激进程度描述映射
- 支持自定义身份块
- 新增"扩展配置"区块

---

## 交互流程

### 输入法使用流程

1. **选择一级主题**：点击顶部操作栏的槽位按钮（帮你回/帮开场/帮润色）
2. **选择二级分类**：在九宫格中点击对应的二级分类
3. **粘贴内容**：点击"粘贴对方消息"按钮读取剪贴板
4. **生成候选**：自动或手动触发 AI 生成
5. **切换候选数量**：点击右上角数字按钮切换显示 2/3 个候选
6. **替换首选**：点击"切"按钮用备选内容替换首选
7. **发送回复**：点击候选内容插入输入框

### 主 App 配置流程

1. 进入"分类配置"页面
2. 选择要编辑的槽位卡片
3. 在编辑页面配置：
   - 自定义主分类名称（可选）
   - 添加/删除二级分类（最多 9 个）
   - 输入身份描述
   - 选择字数多少
   - 选择风险激进程度
4. 保存配置
5. 返回主页，配置自动同步到键盘扩展

---

## 数据结构

### V2 配置 JSON 示例

```json
{
  "slot_id": 0,
  "main_category": "reply",
  "config_v2": {
    "custom_main_name": "智慧回",
    "custom_sub_categories": [
      {"id": "uuid", "name": "暖男", "emoji": "🌊"},
      {"id": "uuid", "name": "高情商", "emoji": "💕"},
      {"id": "uuid", "name": "幽默", "emoji": "😏"}
    ],
    "identity_setting": "我是一名程序员",
    "word_count": "medium",
    "risk_level": "medium"
  }
}
```

### API 请求示例

```json
{
  "main_category": "reply",
  "sub_category": "highEQ",
  "context": {
    "last_message": "好久不见啊"
  },
  "config_v2": {
    "word_count": "中",
    "risk_level": "中",
    "identity": "程序员",
    "display_name": "智慧回",
    "custom_sub_name": "暖男风格"
  },
  "count": 3
}
```

---

## 设计决策

1. **九宫格布局**：选择 3x3 布局以适应键盘高度限制
2. **候选数量切换**：使用简洁的数字按钮，减少视觉干扰
3. **V2 配置向后兼容**：`configV2` 属性可选，不影响现有配置
4. **风险程度影响**：影响提示词中的表达约束，不改变核心功能
5. **身份设置自由输入**：比预设选项更灵活

---

## 待优化项

1. [ ] 二级分类拖拽排序
2. [ ] 二级分类 emoji 选择器
3. [ ] 配置导入/导出功能
4. [ ] 更多预设身份模板
5. [ ] 候选滑动切换手势
