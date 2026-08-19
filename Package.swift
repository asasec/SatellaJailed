// swift-tools-version: 5.4
import PackageDescription

let package = Package(
    name: "JinxSwiftTweak",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "JinxSwiftTweak",
            targets: ["JinxSwiftTweak"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Paisseon/Jinx.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "JinxSwiftTweak",
            dependencies: ["Jinx"],
            path: "Sources"
        )
    ]
)
