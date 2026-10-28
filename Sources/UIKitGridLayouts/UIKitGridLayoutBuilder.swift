import UIKit

/// 将共用的轨道定义转换为指定滚动方向的分区布局。
///
/// 此类型是包内部实现，不属于公开 API。主轴表示滚动方向，交叉轴表示轨道尺寸方向。
@MainActor
enum UIKitGridLayoutBuilder {
    /// 布局的滚动方向。
    enum Axis { case vertical, horizontal }
    /// 轨道间距和主轴间距共用的默认值，单位为点。
    static let defaultSpacing: CGFloat = 8

    /// 创建根据当前有效容器尺寸生成分区布局的闭包。
    ///
    /// - Parameters:
    ///   - definitions: 非空的交叉轴轨道定义数组。
    ///   - axis: 主轴方向。纵向布局计算列宽，横向布局计算行高。
    ///   - alignmentFraction: 交叉轴剩余空间中放在起始边缘的比例；调用方传入 0、0.5 或 1。
    ///   - spacing: 主轴方向的组间距；nil 使用 defaultSpacing。
    ///   - pinnedViews: 页眉与页脚的吸附选项。
    ///   - itemExtent: 单元格在主轴上的固定尺寸。
    ///   - headerExtent: 页眉在主轴上的尺寸；0 表示不创建页眉布局项。
    ///   - footerExtent: 页脚在主轴上的尺寸；0 表示不创建页脚布局项。
    /// - Returns: 为每个分区应用相同轨道定义的布局提供器。
    static func provider(
        tracks definitions: [UIKitGridItem],
        axis: Axis,
        alignmentFraction: CGFloat,
        spacing: CGFloat?,
        pinnedViews: UIKitPinnedScrollableViews,
        itemExtent: CGFloat,
        headerExtent: CGFloat,
        footerExtent: CGFloat
    ) -> UICollectionViewCompositionalLayoutSectionProvider {
        precondition(!definitions.isEmpty, "At least one row or column is required.")
        precondition(itemExtent.isFinite && itemExtent > 0)
        precondition(headerExtent.isFinite && headerExtent >= 0)
        precondition(footerExtent.isFinite && footerExtent >= 0)
        let lineSpacing = spacing ?? defaultSpacing
        precondition(lineSpacing.isFinite && lineSpacing >= 0)
        validate(definitions)

        return { _, environment in
            // contentInsetsReference 与 collection view 的滚动 inset 策略由 UIKit
            // 解析到环境中。使用已应用容器 inset 的尺寸，不重复减 safeAreaInsets。
            // 本 provider 只添加主轴的 section 间距，没有额外的交叉轴 section padding。
            let container = environment.container.effectiveContentSize
            let available = max(1, axis == .vertical ? container.width : container.height)
            let tracks = resolve(definitions, availableExtent: available)
            let totalExtent = tracks.reduce(0) { $0 + $1.extent + $1.spacing }
            let equalSpacing = tracks.dropLast().allSatisfy {
                abs($0.spacing - (tracks.first?.spacing ?? 0)) < 0.001
            }

            let items = tracks.enumerated().map { index, track in
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                    widthDimension: axis == .vertical ? .absolute(track.extent) : .fractionalWidth(1),
                    heightDimension: axis == .vertical ? .fractionalHeight(1) : .absolute(track.extent)
                ))
                if !equalSpacing && index < tracks.count - 1 {
                    item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
                        leading: nil, top: nil,
                        trailing: axis == .vertical ? .fixed(track.spacing) : nil,
                        bottom: axis == .horizontal ? .fixed(track.spacing) : nil
                    )
                }
                return item
            }

            let size = NSCollectionLayoutSize(
                widthDimension: .absolute(axis == .vertical ? totalExtent : itemExtent),
                heightDimension: .absolute(axis == .vertical ? itemExtent : totalExtent)
            )
            // subitems 保留指定尺寸；带 count 的重复 group 会重新分配尺寸。
            let group: NSCollectionLayoutGroup
            if axis == .vertical {
                group = .horizontal(layoutSize: size, subitems: items)
            } else {
                group = .vertical(layoutSize: size, subitems: items)
            }
            if equalSpacing {
                group.interItemSpacing = .fixed(tracks.count > 1 ? tracks[0].spacing : 0)
            }

            let offset = max(0, available - totalExtent) * alignmentFraction
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(
                leading: axis == .vertical ? .fixed(offset) : nil,
                top: axis == .horizontal ? .fixed(offset) : nil,
                trailing: nil, bottom: nil
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = lineSpacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: axis == .vertical && headerExtent > 0 ? lineSpacing : 0,
                leading: axis == .horizontal && headerExtent > 0 ? lineSpacing : 0,
                bottom: axis == .vertical ? lineSpacing : 0,
                trailing: axis == .horizontal ? lineSpacing : 0
            )

            var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
            if headerExtent > 0 {
                supplementaryItems.append(boundary(
                    extent: headerExtent, axis: axis,
                    kind: UICollectionView.elementKindSectionHeader,
                    alignment: axis == .vertical ? .top : .leading,
                    pinned: pinnedViews.contains(.sectionHeaders)
                ))
            }
            if footerExtent > 0 {
                supplementaryItems.append(boundary(
                    extent: footerExtent, axis: axis,
                    kind: UICollectionView.elementKindSectionFooter,
                    alignment: axis == .vertical ? .bottom : .trailing,
                    pinned: pinnedViews.contains(.sectionFooters)
                ))
            }
            section.boundarySupplementaryItems = supplementaryItems
            return section
        }
    }

    /// 创建覆盖整个交叉轴、并具有指定主轴尺寸的分区边界辅助布局项。
    private static func boundary(
        extent: CGFloat,
        axis: Axis,
        kind: String,
        alignment: NSRectAlignment,
        pinned: Bool
    ) -> NSCollectionLayoutBoundarySupplementaryItem {
        let item = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: axis == .vertical ? .fractionalWidth(1) : .absolute(extent),
                heightDimension: axis == .vertical ? .absolute(extent) : .fractionalHeight(1)
            ),
            elementKind: kind,
            alignment: alignment
        )
        item.pinToVisibleBounds = pinned
        item.zIndex = 2
        return item
    }

    /// 验证轨道尺寸与间距的前置条件；无效输入不参与后续尺寸计算。
    private static func validate(_ definitions: [UIKitGridItem]) {
        for definition in definitions {
            let spacing = definition.spacing ?? defaultSpacing
            precondition(spacing.isFinite && spacing >= 0)
            switch definition.size {
            case let .fixed(extent):
                precondition(extent.isFinite && extent > 0)
            case let .flexible(minimum, maximum), let .adaptive(minimum, maximum):
                precondition(minimum.isFinite && minimum > 0 && maximum >= minimum)
            }
        }
    }

    /// 自适应定义展开后的一条实际轨道。
    struct Track {
        /// 交叉轴尺寸，单位为点。
        let extent: CGFloat
        /// 与下一条实际轨道的间距；最后一条轨道为 0。
        var spacing: CGFloat
    }

    /// 将轨道定义解析为具有具体尺寸和间距的实际轨道。
    ///
    /// 先扣除定义间距和固定尺寸，再按顺序分配非固定定义，最后展开 adaptive。
    /// flexible 应用上下限后继续分配剩余空间，不回头重新均分已处理的定义。
    /// adaptive 在其分配区域内确定数量；达到 maximum 后不将空白重新分配给其他定义。
    ///
    /// - Parameters:
    ///   - definitions: 已验证的轨道定义数组。
    ///   - availableExtent: 容器在交叉轴上的有效尺寸，不应再次扣除安全区域。
    /// - Returns: 按原顺序排列的实际轨道，最后一条轨道的尾部间距为 0。
    /// - Note: 这是本包确定的一轮分配规则，不是 SwiftUI 多轮测量算法的完整复刻。
    static func resolve(_ definitions: [UIKitGridItem], availableExtent: CGFloat) -> [Track] {
        let gaps = definitions.map { $0.spacing ?? defaultSpacing }
        var remaining = availableExtent - gaps.dropLast().reduce(0, +)
        var allocated = Array(repeating: CGFloat.zero, count: definitions.count)
        var flexibleCount = 0

        for (index, definition) in definitions.enumerated() {
            if case let .fixed(extent) = definition.size {
                allocated[index] = extent
                remaining -= extent
            } else {
                flexibleCount += 1
            }
        }
        for (index, definition) in definitions.enumerated() {
            switch definition.size {
            case .fixed: continue
            case let .flexible(minimum, maximum):
                allocated[index] = min(maximum, max(minimum, remaining / CGFloat(flexibleCount)))
            case .adaptive:
                allocated[index] = max(1, remaining / CGFloat(flexibleCount))
            }
            remaining -= allocated[index]
            flexibleCount -= 1
        }

        var tracks: [Track] = []
        for (index, definition) in definitions.enumerated() {
            let gap = gaps[index]
            if case let .adaptive(minimum, maximum) = definition.size {
                let count = max(1, Int(floor((allocated[index] + gap) / (minimum + gap))))
                let extent = min(maximum, max(1, (allocated[index] - CGFloat(count - 1) * gap) / CGFloat(count)))
                for _ in 0..<count {
                    tracks.append(Track(extent: extent, spacing: gap))
                }
            } else {
                tracks.append(Track(extent: allocated[index], spacing: gap))
            }
        }
        if !tracks.isEmpty { tracks[tracks.count - 1].spacing = 0 }
        return tracks
    }
}
