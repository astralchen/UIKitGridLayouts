import UIKit
import XCTest
@testable import UIKitGridLayouts

@MainActor
final class ContainerInsetsTests: XCTestCase {
    func testVerticalProviderUsesEffectiveWidthOnce() throws {
        let frame = try firstItemFrame(axis: .vertical)
        // 360 pt fits four columns: (360 - 3 * 12) / 4 = 81.
        XCTAssertEqual(frame.width, 81, accuracy: 0.001)
    }

    func testHorizontalProviderUsesEffectiveHeightOnce() throws {
        let frame = try firstItemFrame(axis: .horizontal)
        // 260 pt fits two rows: (260 - 12) / 2 = 124.
        XCTAssertEqual(frame.height, 124, accuracy: 0.001)
    }

    private func firstItemFrame(axis: UIKitGridLayoutBuilder.Axis) throws -> CGRect {
        let sectionProvider = provider(axis: axis)
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = axis == .vertical ? .vertical : .horizontal
        configuration.contentInsetsReference = .none
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { index, _ in
            sectionProvider(index, TestEnvironment())
        }, configuration: configuration)
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 300),
                                          collectionViewLayout: layout)
        let source = TestDataSource()
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.dataSource = source
        collection.reloadData()
        collection.layoutIfNeeded()
        return try XCTUnwrap(layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))).frame
    }

    func testPublicSafeAreaPolicyCanBeOverridden() {
        let columns = [UIKitGridItem(.flexible())]
        XCTAssertEqual(UIKitLazyVGridLayout(columns: columns).configuration.contentInsetsReference, .safeArea)
        XCTAssertEqual(UIKitLazyHGridLayout(rows: columns).configuration.contentInsetsReference, .safeArea)
        XCTAssertEqual(UIKitLazyVGridLayout(columns: columns, contentInsetsReference: .none)
            .configuration.contentInsetsReference, .none)
        XCTAssertEqual(UIKitLazyHGridLayout(rows: columns, contentInsetsReference: .none)
            .configuration.contentInsetsReference, .none)
    }

    private func provider(axis: UIKitGridLayoutBuilder.Axis) -> UICollectionViewCompositionalLayoutSectionProvider {
        UIKitGridLayoutBuilder.provider(
            tracks: [UIKitGridItem(.adaptive(minimum: 80), spacing: 12)],
            axis: axis,
            alignmentFraction: 0.5,
            spacing: 12,
            pinnedViews: [],
            itemExtent: 56,
            headerExtent: 0,
            footerExtent: 0
        )
    }
}

@MainActor
private final class TestDataSource: NSObject, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 12 }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
}

/// 验证 builder 对 UIKit 提供的有效容器尺寸的消费；不替代真实窗口 safe-area 测试。
@MainActor
private final class TestEnvironment: NSObject, NSCollectionLayoutEnvironment {
    let container: any NSCollectionLayoutContainer = TestContainer()
    let traitCollection = UITraitCollection()
}

@MainActor
private final class TestContainer: NSObject, NSCollectionLayoutContainer {
    let contentSize = CGSize(width: 400, height: 300)
    let effectiveContentSize = CGSize(width: 360, height: 260)
    let contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    var effectiveContentInsets: NSDirectionalEdgeInsets { contentInsets }
}
