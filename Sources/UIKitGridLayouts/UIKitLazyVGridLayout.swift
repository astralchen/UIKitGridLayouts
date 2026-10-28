import UIKit

/// 按列定义排列单元格并沿垂直方向滚动的组合布局。
///
/// 使用 ``UIKitGridItem`` 指定固定、弹性或自适应列。布局为每个分区使用相同的
/// 列定义，并根据布局环境的有效宽度重新计算列宽和自适应列数量。
///
/// 此类型借鉴 SwiftUI LazyVGrid 的参数组织方式。单元格与辅助视图由
/// UICollectionViewDataSource 提供；本布局使用固定行高，不根据单元格内容测量行高。
/// 创建与使用布局时应遵循 UIKit 的主线程隔离要求。
public final class UIKitLazyVGridLayout: UICollectionViewCompositionalLayout {
    /// 未指定轨道间距或行间距时使用的默认值，单位为点。
    public static let defaultSpacing: CGFloat = 8

    /// 使用指定的列定义、对齐方式和分区配置创建纵向网格布局。
    ///
    /// 列宽计算使用 NSCollectionLayoutEnvironment.container.effectiveContentSize，
    /// 不再次扣除 safeAreaInsets。集合视图的约束和 contentInsetAdjustmentBehavior
    /// 由调用方管理；contentInsetsReference 只指定布局使用的内边距参考边界。
    ///
    /// - Parameters:
    ///   - columns: 非空的列定义数组。自适应定义可能展开为多列；每个定义的 spacing
    ///     控制列间距。初始化后修改原数组不会更新此布局，应使用新定义重新创建布局。
    ///   - alignment: 整组列在可用宽度内的水平对齐方式，默认值为 center。
    ///   - spacing: 相邻行之间的间距，单位为点。也用于页眉与内容之间及分区末尾的留白。
    ///     必须是有限非负数；nil 使用 ``defaultSpacing``。
    ///   - pinnedViews: 需要吸附到可见边界的分区辅助视图，默认值为空集合。
    ///   - rowHeight: 每行单元格的高度，单位为点。必须是有限正数，默认值为 56。
    ///   - headerHeight: 分区页眉高度，单位为点。必须是有限非负数；默认值为 0，
    ///     表示不创建页眉布局项。大于 0 时，数据源必须提供 elementKindSectionHeader 视图。
    ///   - footerHeight: 分区页脚高度，单位为点。必须是有限非负数；默认值为 0，
    ///     表示不创建页脚布局项。大于 0 时，数据源必须提供 elementKindSectionFooter 视图。
    ///   - contentInsetsReference: 布局内边距的参考边界，默认值为 safeArea。
    /// - Important: 空列数组或无效尺寸、间距会触发前置条件失败。
    public init(
        columns: [UIKitGridItem],
        alignment: UIKitGridAlignment = .center,
        spacing: CGFloat? = nil,
        pinnedViews: UIKitPinnedScrollableViews = [],
        rowHeight: CGFloat = 56,
        headerHeight: CGFloat = 0,
        footerHeight: CGFloat = 0,
        contentInsetsReference: UIContentInsetsReference = .safeArea
    ) {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = contentInsetsReference
        super.init(
            sectionProvider: UIKitGridLayoutBuilder.provider(
                tracks: columns, axis: .vertical,
                alignmentFraction: alignment.offsetFraction,
                spacing: spacing, pinnedViews: pinnedViews,
                itemExtent: rowHeight, headerExtent: headerHeight, footerExtent: footerHeight
            ),
            configuration: configuration
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init(columns:)") }
}
