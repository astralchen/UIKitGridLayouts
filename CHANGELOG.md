# 更新记录

## 未发布

- 示例和文档：多分区页面新增纵向／横向切换，展示独立 header/footer 尺寸、吸附及背景，以及原生正交轮播；库 API 和源码不变。
- 新增横向多分区真实运行截图与 README 参数说明。

## 0.3.0 — 2026-10-28

- 不兼容 API 调整：V/H 布局和分区工厂统一使用 `itemSize`、`headerSize`、`footerSize`；移除旧的 Height/Width 参数名。
- 新增 `UIKitGridSize.fixed`、`.estimated`、`.aspectRatio` 和 iOS 17+ 的 `.uniform(estimated:)`。比例固定为宽 ÷ 高；cell 按各自轨道计算，group 使用最大主轴尺寸。
- cell 与 group 同时启用 estimated，页眉页脚也支持 self-sizing；辅助视图默认为 nil，替代旧的 0。
- UIKitGridSize 使用封装内部枚举的值类型和静态工厂，仅 uniform 标记 iOS 17+；其他模式继续支持 iOS 15。uniform 的纵向同一行等高、横向同一列等宽，不跨组统一。
- 新增 15 项运行时集成测试，覆盖两个方向和两个公开入口的尺寸策略、内容更新、比例、容器重算与辅助视图，以及 uniform 末组不满、独立分组与 adaptive 成员变化。
- 更新迁移说明与示例；最低 iOS 15 保持不变。

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
