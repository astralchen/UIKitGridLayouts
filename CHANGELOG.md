# 更新记录

## 0.2.0 — 2026-10-28

- 新增纵向和横向 `makeSection` 公共方法，返回 `NSCollectionLayoutSection`，支持每个分区使用不同规则并与原生分区组合。
- 支持分区内边距，在轨道分配前扣除交叉轴留白，保留原布局初始化器的默认行为。
- 新增 5 项公开 API 集成测试，覆盖多分区、留白、原生分区混用、配置隔离和环境变化。
- README 补充多分区用法与两张真实运行截图，安装说明更新为 0.2.0。
- 保持现有布局初始化器的默认行为；最低 iOS 15、Swift tools 6.3 要求不变。

## 0.1.0 — 2026-10-28

首个公开版本：

- 提供 `UIKitGridItem`、`UIKitLazyVGridLayout` 和 `UIKitLazyHGridLayout`，支持 fixed、flexible、adaptive 及混排。
- 支持交叉轴对齐、轨道和主轴间距、页眉页脚吸附及安全区域参考配置。
- 保留中文 API 注释、安装与使用示例、四种模式的纵向和横向共 8 张真实运行截图。
- 保留 14 个包测试，覆盖轨道分配、混排边界和有效容器尺寸、安全区域配置。
- Swift tools 6.3，Swift 6 language mode，最低 iOS 15，仅依赖 UIKit。

具体行为约定与限制见 README；验证记录见 RELEASING。版本标签：`0.1.0`。
