import UIKit

/// 按行定义排列单元格并沿水平方向滚动的组合布局。
///
/// 使用 ``UIKitGridItem`` 指定固定、弹性或自适应行。布局为每个分区使用相同的
/// 行定义，并根据布局环境的有效高度重新计算行高和自适应行数量。
///
/// 此类型借鉴 SwiftUI LazyHGrid 的参数组织方式。单元格与辅助视图由
/// UICollectionViewDataSource 提供；itemSize 支持固定宽度、内容自适应宽度与宽高比。
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
    ///   - itemSize: 主轴尺寸策略，默认 .fixed(56)。支持 .estimated、.uniform（iOS 17+）和 .aspectRatio（宽 ÷ 高）。
    ///   - headerSize: 页眉主轴尺寸策略；nil（默认）不创建页眉，非 nil 时数据源必须提供页眉。
    ///   - footerSize: 页脚主轴尺寸策略；nil（默认）不创建页脚，非 nil 时数据源必须提供页脚。
    ///   - contentInsetsReference: 布局内边距的参考边界，默认值为 safeArea。
    /// - Important: 空行数组或无效尺寸、间距会触发前置条件失败。
    public init(
        rows: [UIKitGridItem],
        alignment: UIKitGridVerticalAlignment = .center,
        spacing: CGFloat? = nil,
        pinnedViews: UIKitPinnedScrollableViews = [],
        itemSize: UIKitGridSize = .fixed(56),
        headerSize: UIKitGridSize? = nil,
        footerSize: UIKitGridSize? = nil,
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
                itemSize: itemSize, headerSize: headerSize, footerSize: footerSize
            ),
            configuration: configuration
        )
    }

    /// 根据当前布局环境创建一个可独立配置的横向网格分区。
    ///
    /// 在 UICollectionViewCompositionalLayout 的 sectionProvider 中调用此方法，
    /// 可按 sectionIndex 为不同分区指定不同行定义，或与 UIKit 原生分区组合。
    /// 每次调用返回一个新的分区；环境变化时应重新创建，不要跨布局环境缓存结果。
    /// 调用方负责配置外层布局的 scrollDirection（水平方向）和 contentInsetsReference。
    /// 返回后可继续设置 decorationItems、辅助视图或其他分区属性。
    ///
    /// - Parameters:
    ///   - rows: 非空的行定义数组；每个定义的 spacing 控制交叉轴间距。
    ///   - alignment: 整组行在剩余高度内的对齐方式，默认值为 center。
    ///   - spacing: 主轴组间距，单位为点。必须是有限非负数；nil 使用 ``defaultSpacing``。
    ///   - pinnedViews: 页眉与页脚的吸附选项，默认值为空集合。
    ///   - itemSize: 主轴尺寸策略，默认 .fixed(56)。支持 .estimated、.uniform（iOS 17+）和 .aspectRatio（宽 ÷ 高）。
    ///   - headerSize: 页眉主轴尺寸策略；nil（默认）不创建页眉，非 nil 时数据源必须提供页眉。
    ///   - footerSize: 页脚主轴尺寸策略；nil（默认）不创建页脚，非 nil 时数据源必须提供页脚。
    ///   - contentInsets: 分区内边距；每项必须是有限非负数。nil 沿用布局初始化器的
    ///     主轴留白规则；非 nil 替换全部四边。top / bottom 在轨道计算前扣除一次。
    ///   - environment: 外层 sectionProvider 本次收到的布局环境。
    /// - Returns: 按当前有效容器尺寸计算的网格分区。
    /// - Important: 创建后修改交叉轴 contentInsets 不会重新计算轨道；请通过参数传入。
    ///   指定非 nil 页眉或页脚尺寸时，数据源仍需提供对应的标准辅助视图。
    public static func makeSection(
        rows: [UIKitGridItem],
        alignment: UIKitGridVerticalAlignment = .center,
        spacing: CGFloat? = nil,
        pinnedViews: UIKitPinnedScrollableViews = [],
        itemSize: UIKitGridSize = .fixed(56),
        headerSize: UIKitGridSize? = nil,
        footerSize: UIKitGridSize? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        environment: any NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        UIKitGridLayoutBuilder.makeSection(
            tracks: rows, axis: .horizontal, alignmentFraction: alignment.offsetFraction,
            spacing: spacing, pinnedViews: pinnedViews,
            itemSize: itemSize, headerSize: headerSize, footerSize: footerSize,
            contentInsets: contentInsets, environment: environment
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init(rows:)") }
}
