# 独立仓库发布说明

本仓库根目录即 Swift Package 根目录，仓库地址为 `https://github.com/astralchen/UIKitGridLayouts`。库仅依赖 UIKit；示例 App 不属于库的构建依赖。

## 版本发布前

1. 确认 `Package.swift` 仍声明 Swift tools 6.3、Swift 6 language mode 和最低 iOS 15。
2. 在包含 Swift 6.3 或更新编译器的 Xcode 中运行 `bash Scripts/test.sh 'platform=iOS Simulator,id=实际UDID'`。记录 Xcode、编译器、运行系统和测试结果。
3. 在示例 App 对比纵向与横向、上限、窄容器、混排顺序与对齐。算法或界面变化后，更新 README 的真实运行截图。
4. 检查 README 的安装说明、公开 API 中文注释、兼容范围以及 CHANGELOG。保留 `Documentation/Screenshots/` 的全部 8 张图片。
5. 检查工作区和将发布的提交，排除构建缓存、个人 Xcode 设置、签名资料和 `.xcresult`。
6. 确定版本号，将 CHANGELOG 的“未发布”条目归入该版本；完成验证后，再为对应提交创建版本标签和 GitHub Release。

当前仅准备仓库，未创建版本标签或 GitHub Release。版本发布前，README 使用 `main` 分支依赖，并说明固定 commit 的选择。

## 验证记录

2026-10-28，针对拆分后的独立仓库：

- Xcode MCP 在 iPhone 17 Pro / iOS 26.5 模拟器运行全部 14 个包测试：14 通过，0 失败，0 跳过。此结果使用当前的 Swift tools 6.3 / iOS 15 manifest；测试工具链为 Xcode 27.1 / Swift 6.4。
- Xcode 26.6 的 Swift 6.3.3 编译器，以 Swift 6 language mode 和 `arm64-apple-ios15.0-simulator` 目标编译全部库源码，通过。此检查验证编译与 API 可用性，不等于 iOS 15 运行时验收。
- Swift 6.3.3 的 SwiftPM manifest 解析通过，确认 tools 6.3、iOS 15.0、Swift 6 language mode 与无外部依赖。
- 检查了全部 8 张 README 图片的引用和内容，截图与拆分前一致。中文注释和所有测试均保留；库行为没有因拆分而改变。

此前在 iPhone 17 Pro / iOS 26.5 模拟器运行并逐张查看 fixed、flexible、adaptive、混合模式的纵向与横向画面。README 保存这些真实截图；截图通过示例 App 的 Debug 启动参数进入配置。

## 验证范围

- 尚未完成 iOS 15 设备或模拟器的运行时验收。
- 混合模式的 SwiftUI / UIKit UI 自动化断言此前受测试宿主启动停滞影响，未取得完整结果；此次包测试通过不代表该项 UI 自动化已完成。
- 不将 API 风格兼容描述为 SwiftUI 全部测量与渲染行为兼容。

后续修改分配算法时，除单元测试外，应在示例 App 对比纵向与横向、上限、窄容器、混排顺序与对齐。发布记录应区分编译兼容、单元测试和设备 UI 验证。
