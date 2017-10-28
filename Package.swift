// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "VaporApp",
    products: [
        .executable(name: "App", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", "4.0.0" ..< "5.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentProvider", "RxSwift", "RxCocoa"],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                ]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)

