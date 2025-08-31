// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GitPeek",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "GitPeek",
            targets: ["GitPeek"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0")
    ],
    targets: [
        .executableTarget(
            name: "GitPeek",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "GitPeek",
            exclude: ["Assets.xcassets", "GitPeek.entitlements"]
        ),
        .testTarget(
            name: "GitPeekTests",
            dependencies: [
                "GitPeek",
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "GitPeekTests"
        )
    ]
)