// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iwasbored",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "iwasbored",
            dependencies: []
        ),
        .executableTarget(
            name: "astGen",
            dependencies: []
        ),
        .testTarget(
            name: "iwasboredTests",
            dependencies: ["iwasbored"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
