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
    ///   - itemSize: 单元格在主轴上的尺寸策略。
    ///   - header: 页眉的 kind 与主轴尺寸配置；nil 表示不创建页眉布局项。
    ///   - footer: 页脚的 kind 与主轴尺寸配置；nil 表示不创建页脚布局项。
    /// - Returns: 为每个分区应用相同轨道定义的布局提供器。
    static func provider(
        tracks definitions: [UIKitGridItem],
        axis: Axis,
        alignmentFraction: CGFloat,
        spacing: CGFloat?,
        pinnedViews: UIKitPinnedScrollableViews,
        itemSize: UIKitGridSize,
        header: UIKitGridBoundaryItem?,
        footer: UIKitGridBoundaryItem?
    ) -> UICollectionViewCompositionalLayoutSectionProvider {
        precondition(!definitions.isEmpty, "At least one row or column is required.")
        itemSize.validate()
        header?.size.validate()
        footer?.size.validate()
        let lineSpacing = spacing ?? defaultSpacing
        precondition(lineSpacing.isFinite && lineSpacing >= 0)
        validate(definitions)

        return { _, environment in
            makeSection(
                tracks: definitions, axis: axis, alignmentFraction: alignmentFraction,
                spacing: lineSpacing, pinnedViews: pinnedViews,
                itemSize: itemSize, header: header, footer: footer,
                environment: environment
            )
        }
    }

    /// 根据当前环境创建一个独立分区；交叉轴内边距在轨道分配前扣除。
    static func makeSection(
        tracks definitions: [UIKitGridItem],
        axis: Axis,
        alignmentFraction: CGFloat,
        spacing: CGFloat?,
        pinnedViews: UIKitPinnedScrollableViews,
        itemSize: UIKitGridSize,
        header: UIKitGridBoundaryItem?,
        footer: UIKitGridBoundaryItem?,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        environment: any NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        precondition(!definitions.isEmpty, "At least one row or column is required.")
        itemSize.validate()
        header?.size.validate()
        footer?.size.validate()
        let lineSpacing = spacing ?? defaultSpacing
        precondition(lineSpacing.isFinite && lineSpacing >= 0)
        validate(definitions)

        if let contentInsets {
            precondition([contentInsets.top, contentInsets.leading, contentInsets.bottom, contentInsets.trailing]
                .allSatisfy { $0.isFinite && $0 >= 0 })
        }

        // contentInsetsReference 与 collection view 的滚动 inset 策略由 UIKit
        // 解析到环境中。使用已应用容器 inset 的尺寸，不重复减 safeAreaInsets。
        // 分区内边距独立于容器安全区域；只扣除调用方指定的交叉轴留白。
        let container = environment.container.effectiveContentSize
        let insets = contentInsets ?? NSDirectionalEdgeInsets(
            top: axis == .vertical && header != nil ? lineSpacing : 0,
            leading: axis == .horizontal && header != nil ? lineSpacing : 0,
            bottom: axis == .vertical ? lineSpacing : 0,
            trailing: axis == .horizontal ? lineSpacing : 0
        )
        let crossInsets = axis == .vertical
            ? insets.leading + insets.trailing : insets.top + insets.bottom
        let available = max(1, (axis == .vertical ? container.width : container.height) - crossInsets)
        let tracks = resolve(definitions, availableExtent: available)
        let totalExtent = tracks.reduce(0) { $0 + $1.extent + $1.spacing }
        let equalSpacing = tracks.dropLast().allSatisfy {
            abs($0.spacing - (tracks.first?.spacing ?? 0)) < 0.001
        }

        let isVertical = axis == .vertical
        let mainExtent = tracks.map {
            itemSize.resolvedExtent(crossExtent: $0.extent, isVertical: isVertical)
        }.max()!
        let groupMainDimension: NSCollectionLayoutDimension
        if itemSize.isSelfSizing {
            groupMainDimension = .estimated(mainExtent)
        } else {
            groupMainDimension = .absolute(mainExtent)
        }
        let items = tracks.enumerated().map { index, track in
            // self-sizing 的 group 始终使用 estimated；uniform 只放在 cell 上，避免统一整个 section。
            // fractional 主轴会阻止内容测量。
            // 比例按每条轨道单独计算，混排时 group 使用最大的主轴尺寸避免重叠。
            let mainDimension = itemSize.dimension(crossExtent: track.extent, isVertical: isVertical)
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: isVertical ? .absolute(track.extent) : mainDimension,
                heightDimension: isVertical ? mainDimension : .absolute(track.extent)
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
            widthDimension: isVertical ? .absolute(totalExtent) : groupMainDimension,
            heightDimension: isVertical ? groupMainDimension : .absolute(totalExtent)
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
        section.contentInsets = insets

        var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
        if let header {
            supplementaryItems.append(boundary(
                size: header.size, crossExtent: available, axis: axis,
                kind: header.elementKind,
                alignment: axis == .vertical ? .top : .leading,
                pinned: pinnedViews.contains(.sectionHeaders)
            ))
        }
        if let footer {
            supplementaryItems.append(boundary(
                size: footer.size, crossExtent: available, axis: axis,
                kind: footer.elementKind,
                alignment: axis == .vertical ? .bottom : .trailing,
                pinned: pinnedViews.contains(.sectionFooters)
            ))
        }
        section.boundarySupplementaryItems = supplementaryItems
        return section
    }

    /// 创建覆盖整个交叉轴、并具有指定主轴尺寸的分区边界辅助布局项。
    private static func boundary(
        size: UIKitGridSize,
        crossExtent: CGFloat,
        axis: Axis,
        kind: String,
        alignment: NSRectAlignment,
        pinned: Bool
    ) -> NSCollectionLayoutBoundarySupplementaryItem {
        let mainDimension = size.dimension(crossExtent: crossExtent, isVertical: axis == .vertical, uniformSiblings: false)
        let item = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: axis == .vertical ? .fractionalWidth(1) : mainDimension,
                heightDimension: axis == .vertical ? mainDimension : .fractionalHeight(1)
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
