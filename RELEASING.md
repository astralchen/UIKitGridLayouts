# 独立仓库发布说明

本仓库根目录即 Swift Package 根目录，仓库地址为 `https://github.com/astralchen/UIKitGridLayouts`。库仅依赖 UIKit；示例 App 不属于库的构建依赖。

## 版本发布前

1. 确认 `Package.swift` 仍声明 Swift tools 6.3、Swift 6 language mode 和最低 iOS 15。
2. 在包含 Swift 6.3 或更新编译器的 Xcode 中运行 `bash Scripts/test.sh 'platform=iOS Simulator,id=实际UDID'`。记录 Xcode、编译器、运行系统和测试结果。
3. 在示例 App 对比纵向与横向、上限、窄容器、混排顺序与对齐。算法或界面变化后，更新 README 的真实运行截图。
4. 检查 README 的安装说明、公开 API 中文注释、兼容范围以及 CHANGELOG。保留 `Documentation/Screenshots/` 中 README 引用的全部图片（0.3.0 共 13 张）。
5. 检查工作区和将发布的提交，排除构建缓存、个人 Xcode 设置、签名资料和 `.xcresult`。
6. 确定版本号，将 CHANGELOG 的“未发布”条目归入该版本；完成验证后，再为对应提交创建版本标签和 GitHub Release。

## 未发布：横向多分区示例

2026-10-28，使用现有 0.3.0 API 扩展多分区示例，库源码与 API 不变。

- 多分区页面支持纵向／横向切换；横向独立配置 header/footer 宽度、起始／结束吸附及背景，末尾分区使用原生纵向正交滚动。
- Xcode MCP 构建通过；在 iPhone 17 Pro / iOS 26.5 上运行 8 项 App 集成测试和 1 项原有横向 SwiftUI 对比 UI 测试，全部通过。新增 3 项测试覆盖横向辅助视图与背景、独立吸附、方向切换和滚动位置重置。
- 实际运行横向页面，查看五种分区并纵向滑动末尾轮播；新增四张真实截图，分别展示固定分区、页眉吸附、页脚吸附和混排／原生轮播。
- 原有主轴尺寸示例、入口和纵横向 uniform 截图均保留；补跑主轴尺寸集成测试通过，覆盖两个方向的内容增减与 uniform 等策略。
- 未重新执行全部包测试或完整 UI 套件；没有 iOS 15 运行时验收结果。

## 0.3.0：统一主轴尺寸

2026-10-28，0.3.0 新增 UIKitGridSize 以及统一的 itemSize/headerSize/footerSize；这是不兼容 API 调整，迁移方式见 README。

版本标签为 `0.3.0`；[GitHub Release](https://github.com/astralchen/UIKitGridLayouts/releases/tag/0.3.0) 包含变更、迁移与安装说明。此次发布整理仅修改文档，Package.swift、Sources 和 Tests 与已验证的 `f06991f` 提交一致，沿用下述结果。

- iPhone 17 Pro / iOS 26.5：包测试 34 通过、0 失败，新增 15 项尺寸策略集成测试。
- 同一模拟器：示例 App 集成测试 5 通过、0 失败，包含实际 UILabel 在两个方向的内容增减、固定、uniform 与比例切换。
- self-sizing 测试通过 UIWindow、完整 Auto Layout 约束与 preferred fitting attributes 触发实际测量。
- Xcode 26.6 工具链，以 Swift 6 模式和 arm64-apple-ios15.0-simulator 目标，对全部库源码 typecheck 通过；不等于 iOS 15 运行时验收。
- iOS 15 目标导出模块和客户端类型检查通过：fixed/estimated/aspectRatio 无需版本判断，uniform 在 #available(iOS 17.0, *) 内可使用；无版本判断的 uniform 调用按预期编译报错。
- 示例 App 实际启动并查看纵向 estimated、纵向 uniform（增加内容）和横向 uniform 页面，新增真实截图。
- 未执行完整 UI 自动化套件或 iOS 15 运行时测试。旧版本记录仅描述对应历史版本。

## 0.2.0：独立分区 API

2026-10-28 新增纵向和横向 `makeSection`、分区内边距，以及多分区组合示例。

- Xcode MCP / Xcode 27.1 / Swift 6.4，在 iPhone 17 Pro / iOS 26.5 运行全部包测试：19 通过，0 失败，0 跳过（新增 5 项公开 API 集成测试）。
- 使用 Swift 6.3.3、Swift 6 language mode 和 iOS 15 Simulator 部署目标编译当前全部库源码，通过。
- 示例 App 与测试目标构建通过；模拟器实际运行多分区页面，查看五种分区并操作原生轮播，保存两张运行截图。
- 版本标签为 `0.2.0`；[GitHub Release](https://github.com/astralchen/UIKitGridLayouts/releases/tag/0.2.0) 包含安装方式与验证范围。示例 submodule 固定到此标签对应提交。
- 0.1.0 的标签和发布内容保持原样。

## 0.1.0

首个版本标签为 `0.1.0`，发布说明见 [GitHub Release](https://github.com/astralchen/UIKitGridLayouts/releases/tag/0.1.0)。该版本 README 使用从 `0.1.0` 开始的 next-minor 版本规则。

本次版本整理只修改文档；`Package.swift`、`Sources` 和 `Tests` 与下述已验证的独立仓库提交一致，沿用该次构建和测试结果。该次发布时，示例仓库的 submodule 固定到 `0.1.0` 标签对应的提交。

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
