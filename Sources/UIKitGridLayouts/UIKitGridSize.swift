import UIKit

/// 视图在滚动方向上的尺寸策略；交叉轴尺寸由轨道或分区宽高决定。
///
/// VGrid 的主轴是高度，HGrid 的主轴是宽度。
/// 固定值、估计值与宽高比都必须是有限正数；隐藏辅助视图请传 nil。
/// 使用工厂方法保留点语法，同时仅对 uniform 施加 iOS 17 可用性限制。
public struct UIKitGridSize: Equatable, Sendable {
    private enum Storage: Equatable, Sendable {
        case fixed(CGFloat)
        case estimated(CGFloat)
        case uniform(CGFloat)
        case aspectRatio(CGFloat)
    }

    private let storage: Storage
    private init(_ storage: Storage) { self.storage = storage }

    /// 固定的主轴尺寸，单位为点。
    public static func fixed(_ size: CGFloat) -> Self { Self(.fixed(size)) }

    /// 主轴的初始估计尺寸，实际尺寸由视图的 Auto Layout 或 preferred fitting attributes 决定。
    /// cell 与 group 同时启用 estimated；同组 cell 不强制拉伸为相同尺寸。
    public static func estimated(_ size: CGFloat) -> Self { Self(.estimated(size)) }

    /// 先测量内容，再让同一行（VGrid）等高或同一列（HGrid）等宽。
    /// 只统一同一 group 的 cell，不跨行/列统一；用于 header/footer 时按 estimated 测量。
    /// 此策略需要测量同组所有 cell，适合每组项目数量较少的网格。
    @available(iOS 17.0, *)
    public static func uniform(estimated size: CGFloat) -> Self { Self(.uniform(size)) }

    /// 宽 ÷ 高。例如 1 为正方形，16.0 / 9 为宽屏比例，两个滚动方向含义相同。
    public static func aspectRatio(_ ratio: CGFloat) -> Self { Self(.aspectRatio(ratio)) }

    func validate() {
        let value: CGFloat
        switch storage {
        case let .fixed(size), let .estimated(size), let .uniform(size), let .aspectRatio(size): value = size
        }
        precondition(value.isFinite && value > 0, "Grid size and aspect ratio must be finite and positive.")
    }

    func resolvedExtent(crossExtent: CGFloat, isVertical: Bool) -> CGFloat {
        switch storage {
        case let .fixed(size), let .estimated(size), let .uniform(size): return size
        case let .aspectRatio(ratio):
            let size = isVertical ? crossExtent / ratio : crossExtent * ratio
            precondition(size.isFinite && size > 0, "Resolved grid size must be finite and positive.")
            return size
        }
    }

    var isSelfSizing: Bool {
        switch storage {
        case .estimated, .uniform: true
        case .fixed, .aspectRatio: false
        }
    }

    @MainActor
    func dimension(crossExtent: CGFloat, isVertical: Bool, uniformSiblings: Bool = true) -> NSCollectionLayoutDimension {
        let extent = resolvedExtent(crossExtent: crossExtent, isVertical: isVertical)
        if #available(iOS 17.0, *), case .uniform = storage, uniformSiblings {
            return .uniformAcrossSiblings(estimate: extent)
        }
        if isSelfSizing { return .estimated(extent) }
        return .absolute(extent)
    }
}
