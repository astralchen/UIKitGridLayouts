import UIKit

/// 描述网格在交叉轴上的尺寸规则及相邻轨道间距。
///
/// 将此类型用于 ``UIKitLazyVGridLayout`` 的列定义，或
/// ``UIKitLazyHGridLayout`` 的行定义。交叉轴是与滚动方向垂直的轴：
/// 纵向网格使用列宽，横向网格使用行高。
///
/// 一个自适应定义可以展开为多列或多行，因此定义数量不一定等于实际轨道数量。
public struct UIKitGridItem: Sendable {
    /// 指定一个或多个行、列在交叉轴上的尺寸分配方式。
    ///
    /// 布局优先预留固定尺寸和间距，再按定义顺序分配剩余空间，最后展开自适应轨道。
    /// 此规则借鉴 SwiftUI 的 GridItem，但不复刻其提议尺寸与多轮测量行为。
    public enum Size: Sendable {
        /// 创建一条具有指定尺寸的轨道。
        ///
        /// 即使容器空间不足，轨道仍保持指定尺寸，因此可能超出容器边界。
        /// 关联值的单位为点，且必须是有限正数。
        case fixed(CGFloat)

        /// 创建一条在指定上下限之间分配尺寸的弹性轨道。
        ///
        /// 提议尺寸为当前剩余空间除以尚未分配的非固定定义数量，然后限制到指定范围。
        /// 空间不足时仍保留最小尺寸；达到最大尺寸后，剩余空间继续分配给后续定义。
        ///
        /// - Parameters:
        ///   - minimum: 最小尺寸，单位为点。必须是有限正数，默认值为 10。
        ///   - maximum: 最大尺寸，单位为点。不得小于 minimum，默认值为正无穷大。
        case flexible(minimum: CGFloat = 10, maximum: CGFloat = .infinity)

        /// 在分得的区域内创建一条或多条自适应轨道。
        ///
        /// 布局根据 minimum 和轨道间距计算能容纳的数量，再均分该区域并对每条轨道
        /// 应用 maximum。达到最大尺寸后可能留下未使用空间。
        ///
        /// minimum 用于决定展开数量，不是空间不足时的硬性下限。
        /// 此时单条轨道可以小于 minimum；本包在计算中将可分配尺寸保底为 1 点。
        ///
        /// - Parameters:
        ///   - minimum: 计算展开数量时使用的最小尺寸，单位为点。必须是有限正数。
        ///   - maximum: 每条展开轨道的最大尺寸，单位为点。不得小于 minimum，
        ///     默认值为正无穷大。
        case adaptive(minimum: CGFloat, maximum: CGFloat = .infinity)
    }

    /// 此行或列使用的尺寸分配规则。
    public var size: Size
    /// 此轨道与下一条轨道之间的交叉轴间距，单位为点。
    ///
    /// nil 使用本包默认值 8。自适应定义展开出的轨道之间也使用此间距，
    /// 最后一条实际轨道之后不添加间距。此属性不控制滚动方向上的行间距或列间距。
    public var spacing: CGFloat?

    /// 使用指定的尺寸规则和间距创建网格轨道定义。
    ///
    /// - Parameters:
    ///   - size: 行或列的尺寸规则，默认值为 flexible(minimum: 10, maximum: .infinity)。
    ///   - spacing: 与下一条轨道的间距，单位为点。必须是有限非负数；nil 表示 8 点。
    /// - Important: 布局初始化或调用分区工厂时验证参数。违反尺寸或间距约束会触发前置条件失败。
    public init(_ size: Size = .flexible(), spacing: CGFloat? = nil) {
        self.size = size
        self.spacing = spacing
    }
}

/// 指定纵向网格中整组列的水平对齐方式。
///
/// 对齐作用于轨道总宽度小于可用宽度时的剩余空间，不改变单元格内部内容的对齐。
/// 轨道超出容器时不通过负偏移进行居中或尾部对齐。
public enum UIKitGridAlignment: String, Sendable, CaseIterable, Identifiable {
    /// 与容器的起始边缘对齐。
    case leading
    /// 在容器的可用宽度内居中。
    case center
    /// 与容器的结束边缘对齐。
    case trailing
    /// 用于标识此对齐选项的稳定值。
    public var id: Self { self }

    var offsetFraction: CGFloat {
        switch self {
        case .leading: return 0
        case .center: return 0.5
        case .trailing: return 1
        }
    }
}

/// 指定横向网格中整组行的垂直对齐方式。
///
/// 对齐作用于轨道总高度小于可用高度时的剩余空间，不改变单元格内部内容的对齐。
/// 轨道超出容器时不通过负偏移进行居中或底部对齐。
public enum UIKitGridVerticalAlignment: String, Sendable {
    /// 与容器顶部对齐。
    case top
    /// 在容器的可用高度内居中。
    case center
    /// 与容器底部对齐。
    case bottom

    var offsetFraction: CGFloat {
        switch self {
        case .top: return 0
        case .center: return 0.5
        case .bottom: return 1
        }
    }
}

/// 指定滚动时吸附到可见边界的分区辅助视图。
///
/// 可组合页眉和页脚选项，或使用空集合关闭吸附。此选项只设置布局属性，
/// 不创建视图；调用方还需指定正数的页眉或页脚尺寸，并通过数据源提供相应视图。
public struct UIKitPinnedScrollableViews: OptionSet, Sendable {
    /// 选项集合的原始位掩码。
    public let rawValue: Int
    /// 使用指定的位掩码创建选项集合。
    ///
    /// - Parameter rawValue: 包含一个或多个吸附选项的位掩码。
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// 吸附分区页眉。纵向布局使用顶部，横向布局使用起始边缘。
    public static let sectionHeaders = Self(rawValue: 1 << 0)
    /// 吸附分区页脚。纵向布局使用底部，横向布局使用结束边缘。
    public static let sectionFooters = Self(rawValue: 1 << 1)
}
