// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "StubPlay",
    platforms: [
        .iOS(.v10),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "StubPlay",
            targets: ["StubPlay"]),
    ],
    dependencies: [
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0"))
        // because package stubplay is required using a version-based requirement and it depends on unversion package swifter and root depends on StubPlay 0.1.9, version solving failed.
        // .package(name: "Swifter", path: "Vendor/swifter")
    ],
    targets: [
        .target(
            name: "StubPlay",
            dependencies: ["Swifter"],
            path: "Source"
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["StubPlay"],
            path: "Tests",
            
            resources: [
                .copy("FilesManager"),
                .copy("StubFolderCache"),
                .copy("StubURLProtocol"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
