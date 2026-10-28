import UIKit

/// 网格分区页眉或页脚的配置，将辅助视图类型标识与主轴尺寸绑定。
///
/// 用于 VGrid / HGrid 初始化器和 makeSection 的 header、footer 参数，最低支持 iOS 15。
/// 不提供默认 elementKind；调用方可显式使用 UIKit 标准 kind 或自己的非空字符串。
/// 布局、注册与数据源必须使用同一个 kind。位置由 header / footer 决定，
/// 吸附由 pinnedViews 决定，均不依赖 kind 的字符串内容。
public struct UIKitGridBoundaryItem: Equatable, Sendable {
    /// 辅助视图类型标识；与 reuse identifier 是不同的概念。
    public let elementKind: String
    /// 滚动方向上的尺寸策略：纵向为高度，横向为宽度。
    public let size: UIKitGridSize

    /// 创建边界辅助视图配置。
    /// - Parameters:
    ///   - elementKind: 非空的辅助视图类型标识，注册与数据源应使用相同值。
    ///   - size: 主轴尺寸策略；支持 fixed、estimated、aspectRatio 以及 iOS 17+ 的 uniform。
    ///     边界视图的 uniform 按 estimated 独立测量，不与 cell 或其他边界统一尺寸。
    /// - Important: 空 kind 或无效尺寸会触发前置条件失败。隐藏视图请将 header / footer 设为 nil。
    public init(elementKind: String, size: UIKitGridSize) {
        precondition(!elementKind.isEmpty, "Supplementary element kind must not be empty.")
        size.validate()
        self.elementKind = elementKind
        self.size = size
    }
}
