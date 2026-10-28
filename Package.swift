// swift-tools-version: 6.3
import PackageDescription

// 仅依赖 UIKit；测试需要在 Xcode 的 iOS Simulator 目标上运行。
let package = Package(
    name: "UIKitGridLayouts",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "UIKitGridLayouts", targets: ["UIKitGridLayouts"])
    ],
    targets: [
        .target(name: "UIKitGridLayouts"),
        .testTarget(name: "UIKitGridLayoutsTests", dependencies: ["UIKitGridLayouts"])
    ],
    swiftLanguageModes: [.v6]
)
