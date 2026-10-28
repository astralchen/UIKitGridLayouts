# 独立仓库发布说明

本仓库根目录即 Swift Package 根目录，仓库地址为 `https://github.com/astralchen/UIKitGridLayouts`。库仅依赖 UIKit；示例 App 不属于库的构建依赖。

## 版本发布前

1. 确认 `Package.swift` 仍声明 Swift tools 6.3、Swift 6 language mode 和最低 iOS 15。
2. 在包含 Swift 6.3 或更新编译器的 Xcode 中运行 `bash Scripts/test.sh 'platform=iOS Simulator,id=实际UDID'`。记录 Xcode、编译器、运行系统和测试结果。
3. 在示例 App 对比纵向与横向、上限、窄容器、混排顺序与对齐。算法或界面变化后，更新 README 的真实运行截图。
4. 检查 README 的安装说明、公开 API 中文注释、兼容范围以及 CHANGELOG。保留 `Documentation/Screenshots/` 中 README 引用的全部图片（当前工作区共 21 张）。
5. 检查工作区和将发布的提交，排除构建缓存、个人 Xcode 设置、签名资料和 `.xcresult`。
6. 确定版本号，将 CHANGELOG 的“未发布”条目归入该版本；完成验证后，再为对应提交创建版本标签和 GitHub Release。

## 0.5.0：显式边界辅助视图配置

2026-10-28，新增 `UIKitGridBoundaryItem(elementKind:size:)`，用 `header` / `footer` 替代旧 `headerSize` / `footerSize`。不提供兼容重载或默认 kind；调用方显式选择标准或自定义名称。迁移说明见 README。

- Xcode 27.1（27A9275）/ Swift 6.4；iPhone 17 Pro / iOS 26.5 模拟器。
- 更新后的示例构建、安装、启动成功；全部 36 项库测试通过，0 失败、0 跳过。新增测试覆盖两个方向和两种入口的自定义 kind 实际数据源回调与 estimated 测量，以及配置为空、角色对应的位置与吸附标志。
- 全部 8 项示例集成测试通过；新增 1 项 UI 测试通过，从首页打开自定义 Kind 页面，切换纵横方向和初始化器 / makeSection，核对实际辅助视图的可见性和 kind 文本。未执行其余完整 UI 自动化套件。
- 新增 `custom-kinds-vertical.png` / `custom-kinds-horizontal.png`，并更新两张 `api-naming-*.png`。均实际启动 App 截取并逐张检查，分别保存于库与示例的 Documentation/Screenshots，由两个 README 引用。
- 自定义 Kind 截图配置：单条 64 pt 轨道、3 个 48 pt 单元格、header/footer 为 72 pt、间距 8 pt、不吸附；页面可切换 makeSection。标准 kind 示例仍保留但均改为显式配置。
- 全部库源码以 Swift 6 language mode、`arm64-apple-ios15.0-simulator` 目标导出模块成功；独立客户端使用新配置调用四个公开入口并进行类型检查，通过。uniform 在 iOS 17 可用性判断内使用。这是编译兼容性证据，不是 iOS 15 运行时验收。
- 库与示例的 diff --check 通过。版本标签为 `0.5.0`；[GitHub Release](https://github.com/astralchen/UIKitGridLayouts/releases/tag/0.5.0) 提供破坏性变更、迁移和安装说明。示例同步固定到该标签对应的库提交。此次发布整理仅修改版本文档，源码、测试与截图沿用本节已验证内容。
- 没有真机或 iOS 15 运行时验收结果；现有运行证据仅覆盖上述模拟器配置。

## 0.4.0：SwiftUI 风格的对齐类型命名

2026-10-28，`UIKitGridAlignment` 直接重命名为 `UIKitGridHorizontalAlignment`；VGrid 初始化器和 `makeSection` 同步使用新类型。HGrid 保留 `UIKitGridVerticalAlignment`；`columns:` / `rows:` / `alignment:` 标签保持 SwiftUI 风格。

版本标签为 `0.4.0`；[GitHub Release](https://github.com/astralchen/UIKitGridLayouts/releases/tag/0.4.0) 包含破坏性变更、迁移和安装说明。本次版本整理仅更新文档，Package.swift、Sources、Tests 和截图与已验证的 `1aefebf` 提交一致，沿用下述测试和运行结果。示例内部命名清理后的 8 项集成测试也已全部通过。

- Xcode 27.1（27A9275），iPhone 17 Pro / iOS 26.5：示例构建与启动成功；Xcode 包工作区执行 34 项库测试，全部通过；示例执行 8 项集成测试，全部通过。
- 测试覆盖两个方向的分区工厂、轨道尺寸、安全区域、主轴尺寸及内容更新；本次未新增测试或修改分配算法。
- Xcode 27.1 工具链以 Swift 6 模式、`arm64-apple-ios15.0-simulator` 部署目标对全部库源码执行 typecheck，通过；此项是编译兼容性检查，不是 iOS 15 运行验收。
- 实际启动更新后的两个方向参数代码页，逐张检查完整类型名及 columns/rows 调用；新截图为 `api-naming-vertical.png` 和 `api-naming-horizontal.png`，分别保存在两个仓库的 Documentation/Screenshots 并由各自 README 引用。
- Debug 启动参数 `--grid-api` 可重复打开代码页，另加 `--grid-axis horizontal` 选择横向。截图使用 fixed、3 条 72 pt 轨道、center、间距 12 pt 和页眉。
- 沙箱内运行 Scripts/test.sh 时无法连接 CoreSimulator，且 xcodebuild 未识别包目录；上述测试结果来自 Xcode MCP 对实际 submodule 包工作区与示例工程的测试运行。
- 未执行完整 UI 自动化套件、真机或 iOS 15 运行时验收。示例 submodule 固定到 `0.4.0` 标签对应提交。

### 0.4.0 附带的横向多分区示例验证

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
