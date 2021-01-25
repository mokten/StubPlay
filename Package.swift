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
        // Here we define our package's external dependencies
        // and from where they can be fetched:
        .package(name: "Swifter", path: "Vendor/swifter")
    ],
    targets: [
        .target(
            name: "StubPlay",
            dependencies: ["Swifter"],
            path: "Source")
    ],
    swiftLanguageVersions: [.v5]
)
