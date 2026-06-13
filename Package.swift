// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KajiGauge",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "KajiGauge",
            path: "Sources/KajiGauge"
        )
    ]
)
