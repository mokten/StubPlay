// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "StubPlay",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v11)
    ],
    products: [
        .library(name: "StubPlay", targets: ["StubPlay"]),
        .library(name: "StubPlayUnitTest", targets: ["StubPlayUnitTest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mokten/swifter.git", .exactItem("1.5.1"))
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
        .target(name: "StubPlayUnitTest", dependencies: ["StubPlay"], path: "SourceUnitTest", exclude:[]),
    ],
    swiftLanguageVersions: [.v5]
)
