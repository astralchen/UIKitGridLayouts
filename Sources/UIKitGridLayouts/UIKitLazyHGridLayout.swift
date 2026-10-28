import UIKit

/// 按行定义排列单元格并沿水平方向滚动的组合布局。
///
/// 使用 ``UIKitGridItem`` 指定固定、弹性或自适应行。布局为每个分区使用相同的
/// 行定义，并根据布局环境的有效高度重新计算行高和自适应行数量。
///
/// 此类型借鉴 SwiftUI LazyHGrid 的参数组织方式。单元格与辅助视图由
/// UICollectionViewDataSource 提供；本布局使用固定列宽，不根据单元格内容测量列宽。
/// 创建与使用布局时应遵循 UIKit 的主线程隔离要求。
public final class UIKitLazyHGridLayout: UICollectionViewCompositionalLayout {
    /// 未指定轨道间距或列间距时使用的默认值，单位为点。
    public static let defaultSpacing: CGFloat = 8

    /// 使用指定的行定义、对齐方式和分区配置创建横向网格布局。
    ///
    /// 行高计算使用 NSCollectionLayoutEnvironment.container.effectiveContentSize，
    /// 不再次扣除 safeAreaInsets。集合视图的约束和 contentInsetAdjustmentBehavior
    /// 由调用方管理；contentInsetsReference 只指定布局使用的内边距参考边界。
    ///
    /// - Parameters:
    ///   - rows: 非空的行定义数组。自适应定义可能展开为多行；每个定义的 spacing
    ///     控制行间距。初始化后修改原数组不会更新此布局，应使用新定义重新创建布局。
    ///   - alignment: 整组行在可用高度内的垂直对齐方式，默认值为 center。
    ///   - spacing: 相邻列之间的间距，单位为点。也用于页眉与内容之间及分区末尾的留白。
    ///     必须是有限非负数；nil 使用 ``defaultSpacing``。
    ///   - pinnedViews: 需要吸附到可见边界的分区辅助视图，默认值为空集合。
    ///   - columnWidth: 每列单元格的宽度，单位为点。必须是有限正数，默认值为 56。
    ///   - headerWidth: 分区页眉宽度，单位为点。必须是有限非负数；默认值为 0，
    ///     表示不创建页眉布局项。大于 0 时，数据源必须提供 elementKindSectionHeader 视图。
    ///   - footerWidth: 分区页脚宽度，单位为点。必须是有限非负数；默认值为 0，
    ///     表示不创建页脚布局项。大于 0 时，数据源必须提供 elementKindSectionFooter 视图。
    ///   - contentInsetsReference: 布局内边距的参考边界，默认值为 safeArea。
    /// - Important: 空行数组或无效尺寸、间距会触发前置条件失败。
    public init(
        rows: [UIKitGridItem],
        alignment: UIKitGridVerticalAlignment = .center,
        spacing: CGFloat? = nil,
        pinnedViews: UIKitPinnedScrollableViews = [],
        columnWidth: CGFloat = 56,
        headerWidth: CGFloat = 0,
        footerWidth: CGFloat = 0,
        contentInsetsReference: UIContentInsetsReference = .safeArea
    ) {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        configuration.contentInsetsReference = contentInsetsReference
        super.init(
            sectionProvider: UIKitGridLayoutBuilder.provider(
                tracks: rows, axis: .horizontal,
                alignmentFraction: alignment.offsetFraction,
                spacing: spacing, pinnedViews: pinnedViews,
                itemExtent: columnWidth, headerExtent: headerWidth, footerExtent: footerWidth
            ),
            configuration: configuration
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init(rows:)") }
}
