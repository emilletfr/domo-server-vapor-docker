import PackageDescription

let package = Package(
    name: "VaporApp",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 2),
        .Package(url: "https://github.com/vapor/sqlite-provider", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/ReactiveX/RxSwift.git", majorVersion: 3)

      ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests"
    ]
)
