import UIKit
import XCTest
import UIKitGridLayouts

/// 使用公开 API 验证独立分区在组合布局中的实际尺寸。
@MainActor
final class SectionFactoryTests: XCTestCase {
    func testVerticalSectionsUseIndependentDefinitionsAndInsets() throws {
        let frames = try itemFrames(horizontal: false) { index, environment in
            if index == 0 {
                return UIKitLazyVGridLayout.makeSection(
                    columns: [UIKitGridItem(.fixed(70))], alignment: .leading,
                    spacing: 5, rowHeight: 30, environment: environment
                )
            }
            return UIKitLazyVGridLayout.makeSection(
                columns: [UIKitGridItem(.adaptive(minimum: 80), spacing: 12)],
                spacing: 17, rowHeight: 60,
                contentInsets: NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20),
                environment: environment
            )
        }
        XCTAssertEqual(frames[0].width, 70, accuracy: 0.001)
        XCTAssertEqual(frames[0].height, 30, accuracy: 0.001)
        // 有效宽度 360，扣除分区留白 40 后展开三列，未重复扣除容器 inset。
        XCTAssertEqual(frames[1].width, 296.0 / 3, accuracy: 0.001)
        XCTAssertEqual(frames[1].height, 60, accuracy: 0.001)
        XCTAssertGreaterThan(frames[1].minY, frames[0].maxY)
    }

    func testHorizontalSectionsUseIndependentDefinitionsAndInsets() throws {
        let frames = try itemFrames(horizontal: true) { index, environment in
            if index == 0 {
                return UIKitLazyHGridLayout.makeSection(
                    rows: [UIKitGridItem(.fixed(45))], alignment: .top,
                    spacing: 3, columnWidth: 40, environment: environment
                )
            }
            return UIKitLazyHGridLayout.makeSection(
                rows: [UIKitGridItem(.adaptive(minimum: 80), spacing: 12)],
                spacing: 19, columnWidth: 90,
                contentInsets: NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0),
                environment: environment
            )
        }
        XCTAssertEqual(frames[0].height, 45, accuracy: 0.001)
        XCTAssertEqual(frames[0].width, 40, accuracy: 0.001)
        // 有效高度 260，扣除上下各 20 后，两行各为 (220 - 12) / 2。
        XCTAssertEqual(frames[1].height, 104, accuracy: 0.001)
        XCTAssertEqual(frames[1].width, 90, accuracy: 0.001)
        XCTAssertGreaterThan(frames[1].minX, frames[0].maxX)
    }

    func testGridCanCoexistWithNativeSection() throws {
        let frames = try itemFrames(horizontal: false) { index, environment in
            if index == 0 {
                return UIKitLazyVGridLayout.makeSection(
                    columns: [UIKitGridItem(.flexible())], rowHeight: 44, environment: environment
                )
            }
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)
            ))
            return NSCollectionLayoutSection(group: .horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(80)),
                subitems: [item]
            ))
        }
        XCTAssertEqual(frames[0].width, 360, accuracy: 0.001)
        XCTAssertEqual(frames[0].height, 44, accuracy: 0.001)
        XCTAssertEqual(frames[1].width, 200, accuracy: 0.001)
        XCTAssertEqual(frames[1].height, 80, accuracy: 0.001)
    }

    func testSectionCustomizationAndSupplementariesAreIndependent() throws {
        let first = UIKitLazyVGridLayout.makeSection(
            columns: [UIKitGridItem(.flexible())], spacing: 12,
            pinnedViews: [.sectionHeaders, .sectionFooters], headerHeight: 32, footerHeight: 20,
            environment: SectionEnvironment()
        )
        let second = UIKitLazyVGridLayout.makeSection(
            columns: [UIKitGridItem(.flexible())], environment: SectionEnvironment()
        )
        first.decorationItems = [.background(elementKind: "background")]
        first.interGroupSpacing = 24
        XCTAssertTrue(second.decorationItems.isEmpty)
        XCTAssertTrue(second.boundarySupplementaryItems.isEmpty)
        XCTAssertEqual(second.interGroupSpacing, 8)
        XCTAssertEqual(first.boundarySupplementaryItems.map(\.elementKind), [
            UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter
        ])
        XCTAssertTrue(first.boundarySupplementaryItems.allSatisfy(\.pinToVisibleBounds))
        XCTAssertEqual(first.contentInsets.top, 12)
        XCTAssertEqual(first.contentInsets.bottom, 12)
    }

    func testAdaptiveSectionRecomputesWhenEnvironmentChanges() throws {
        var environment = SectionEnvironment(width: 360)
        var observedWidths: [CGFloat] = []
        let layout = UICollectionViewCompositionalLayout { _, _ in
            UIKitLazyVGridLayout.makeSection(
                columns: [UIKitGridItem(.adaptive(minimum: 80), spacing: 12)],
                environment: environment
            )
        }
        let source = SectionDataSource()
        let collection = makeCollection(layout: layout, source: source)
        for width: CGFloat in [360, 320] {
            environment = SectionEnvironment(width: width)
            layout.invalidateLayout()
            collection.layoutIfNeeded()
            observedWidths.append(try XCTUnwrap(layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))).size.width)
        }
        XCTAssertEqual(observedWidths[0], 81, accuracy: 0.001)
        XCTAssertEqual(observedWidths[1], 296.0 / 3, accuracy: 0.001)
    }

    private func itemFrames(
        horizontal: Bool,
        provider: @escaping UICollectionViewCompositionalLayoutSectionProvider
    ) throws -> [CGRect] {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = horizontal ? .horizontal : .vertical
        configuration.contentInsetsReference = .none
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { index, _ in
            provider(index, SectionEnvironment())
        }, configuration: configuration)
        let source = SectionDataSource()
        let collection = makeCollection(layout: layout, source: source)
        collection.layoutIfNeeded()
        return try (0..<2).map {
            try XCTUnwrap(layout.layoutAttributesForItem(at: IndexPath(item: 0, section: $0))).frame
        }
    }

    private func makeCollection(layout: UICollectionViewLayout, source: SectionDataSource) -> UICollectionView {
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 300), collectionViewLayout: layout)
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.dataSource = source
        collection.reloadData()
        collection.layoutIfNeeded()
        return collection
    }
}

@MainActor
private final class SectionDataSource: NSObject, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 6 }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
}

@MainActor
private final class SectionEnvironment: NSObject, NSCollectionLayoutEnvironment {
    let container: any NSCollectionLayoutContainer
    let traitCollection = UITraitCollection()
    init(width: CGFloat = 360) { container = SectionContainer(width: width) }
}

@MainActor
private final class SectionContainer: NSObject, NSCollectionLayoutContainer {
    let contentSize = CGSize(width: 400, height: 300)
    let effectiveContentSize: CGSize
    let contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    var effectiveContentInsets: NSDirectionalEdgeInsets { contentInsets }
    init(width: CGFloat) { effectiveContentSize = CGSize(width: width, height: 260) }
}
