// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "StubPlay",
    platforms: [
        .iOS(.v10),
        .tvOS(.v11),
        .macOS(.v11)
    ],
    products: [
        .library(name: "StubPlay", targets: ["StubPlay"])
    ],
    dependencies: [
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", .revision("eea4bb1e652c2e7aaf09bab39065b1c81a36d2e1")) // Sep 28, 2021
    ],
    targets: [
        .target(name: "StubPlay", dependencies: ["Swifter"], path: "Source", exclude:["Info.plist"]),
        .testTarget(name: "Tests", dependencies: ["StubPlay"], path: "Tests",
                    exclude: ["Stub/StubFiles",
                              "Info.plist",
                              "TestPlans",
                              "HlsPlaylist/HlsPlaylist/simple.m3u8"
                             ],
                    resources: [
                        .copy("FilesManager"),
                        .copy("StubFolderCache"),
                        .copy("StubURLProtocol"),
                    ]
                   ),
    ],
    swiftLanguageVersions: [.v5]
)
