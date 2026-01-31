# Forlove Keyboard V2 改进总结

根据 `m4.txt` 规范完成的改进任务。

## 📋 改进任务清单

### ✅ 1. 数据模型重构 - 从"散装"变为"矩阵"结构

**新增文件：** `SharedKit/Models/CategorySlot.swift`

实现了：
- `MainCategory` 枚举：6 大主分类（帮你回、帮开场、帮润色、夸捧模式、法律专家、生活百科）
- `SubCategory` 枚举：每个主分类的子分类及其 `promptCore` 提示词核心
- `StyleParams` 结构：风格参数（暧昧等级、表情密度、字数长度）
- `CategorySlot` 结构：分类槽位配置
- `UserSlotConfiguration` 结构：用户槽位配置（支持 3 个激活槽位）

### ✅ 2. 统一提示词生成引擎

**新增文件：** `SharedKit/Prompting/PromptEngine.swift`

实现了 m4.txt 规范的提示词拼装公式：
```
Identity + Main_Category_Task + Sub_Category_Style + Global_Constraints
```

包含方法：
- `buildSystemPrompt()` - 构建系统提示词
- `buildUserPrompt()` - 根据分类自动选择构建方法
- `buildReplyUserPrompt()` - 帮你回用户提示词
- `buildOpenerUserPrompt()` - 帮开场用户提示词
- `buildPolishUserPrompt()` - 帮润色用户提示词
- `buildPraiseUserPrompt()` - 夸捧模式用户提示词
- `buildLegalUserPrompt()` - 法律专家用户提示词
- `buildLifeWikiUserPrompt()` - 生活百科用户提示词

### ✅ 3. 存储层更新

**修改文件：**
- `SharedKit/Storage/Keys.swift` - 添加槽位配置存储键
- `SharedKit/Storage/AppGroupStore.swift` - 添加槽位配置存储方法

新增方法：
- `saveSlotConfiguration()` / `loadSlotConfiguration()`
- `saveActiveSlotIndex()` / `loadActiveSlotIndex()`
- `loadActiveSlot()`

### ✅ 4. 服务端 PHP 更新

**修改文件：**
- `Server/prompts.php` - 支持 6 大分类的提示词模板
- `Server/generate.php` - 支持 main_category/sub_category 参数

新增支持：
- 6 大主分类及其子分类
- 风格参数传递
- 向后兼容旧的 intent/tag 字段

### ✅ 5. 键盘状态管理更新

**修改文件：** `ForloveKeyboardExtension/State/KeyboardState.swift`

实现了：
- 槽位配置加载和切换
- 当前激活槽位管理
- 候选选择状态（支持第 1 项填充，第 2/3 项替换）
- 向后兼容旧的 Intent 系统

### ✅ 6. 网络客户端更新

**修改文件：** `ForloveKeyboardExtension/Services/ExtensionNetworkClient.swift`

新增方法：
- `generate(slot:content:identity:chatContext:completion:)` - 使用槽位发送请求
- 子分类到服务端字符串的映射

### ✅ 7. 键盘 UI 新增视图

**新增文件：**
- `ForloveKeyboardExtension/Views/SlotTabsView.swift` - 槽位标签栏
- `ForloveKeyboardExtension/Views/CompactCandidateCardView.swift` - 紧凑候选卡片

功能：
- 显示用户激活的 3 个槽位
- 支持槽位切换
- 第 2/3 项候选显示前 30 字预览

### ✅ 8. 主 App 槽位配置页面

**新增文件：** `ForloveHostApp/Scenes/SlotConfiguration/SlotConfigurationViewController.swift`

包含：
- `SlotConfigurationViewController` - 槽位配置主页面
- `SlotCardView` - 槽位卡片视图
- `SlotEditViewController` - 槽位编辑页面

功能：
- 显示 6 个分类槽位
- 勾选激活/取消激活（最多 3 个）
- 编辑子分类和风格参数
- 保存配置到 App Group

**修改文件：** `ForloveHostApp/Scenes/Home/HomeViewController.swift`

- 添加"分类配置"入口卡片

### ✅ 9. 文档更新

**修改文件：** `README.md`

- 更新为 V2 矩阵结构文档
- 添加 6 大分类说明
- 更新工程结构
- 添加更新日志

## 📁 新增/修改文件列表

| 文件路径 | 操作 | 说明 |
|---------|------|------|
| `SharedKit/Models/CategorySlot.swift` | 新增 | 分类槽位模型 |
| `SharedKit/Prompting/PromptEngine.swift` | 新增 | 统一提示词引擎 |
| `SharedKit/Storage/Keys.swift` | 修改 | 添加槽位存储键 |
| `SharedKit/Storage/AppGroupStore.swift` | 修改 | 添加槽位存储方法 |
| `Server/prompts.php` | 重写 | 支持 6 大分类 |
| `Server/generate.php` | 重写 | 支持新分类参数 |
| `ForloveKeyboardExtension/State/KeyboardState.swift` | 重写 | 支持槽位系统 |
| `ForloveKeyboardExtension/Services/ExtensionNetworkClient.swift` | 重写 | 支持槽位 API |
| `ForloveKeyboardExtension/Views/SlotTabsView.swift` | 新增 | 槽位标签栏 |
| `ForloveKeyboardExtension/Views/CompactCandidateCardView.swift` | 新增 | 紧凑候选卡片 |
| `ForloveHostApp/Scenes/SlotConfiguration/SlotConfigurationViewController.swift` | 新增 | 槽位配置页面 |
| `ForloveHostApp/Scenes/Home/HomeViewController.swift` | 修改 | 添加配置入口 |
| `README.md` | 重写 | V2 文档 |

## 🔄 向后兼容性

所有改进都保持了向后兼容：
- 旧的 `GenerationIntent` 枚举继续有效
- 旧的 `ToneTag` 枚举继续有效
- 旧的 `GenSpec` 结构继续有效
- 旧的 API 参数（intent/tag）继续支持

## 🚀 下一步

1. 在 Xcode 中运行 `xcodegen generate` 重新生成项目
2. 编译并测试主 App 的"分类配置"功能
3. 编译并测试键盘扩展的槽位切换功能
4. 部署更新后的 PHP 文件到服务器
5. 端到端测试完整功能链路

---

改进任务已按照 m4.txt 规范完成。
