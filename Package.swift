// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "EulerLiveKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "EulerLiveKit",
            targets: ["EulerLiveKit"]
        )
    ],
    targets: [
        .target(
            name: "EulerLiveKit",
            path: "Sources/EulerLiveKit"
        ),
        .testTarget(
            name: "EulerLiveKitTests",
            dependencies: ["EulerLiveKit"],
            path: "Tests/EulerLiveKitTests"
        )
    ]
)
