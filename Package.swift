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
    dependencies: [],
    targets: [
        .executableTarget(
            name: "GitPeek",
            dependencies: [],
            path: "GitPeek",
            exclude: ["Assets.xcassets", "GitPeek.entitlements"]
        ),
        .testTarget(
            name: "GitPeekTests",
            dependencies: ["GitPeek"],
            path: "GitPeekTests"
        )
    ]
)