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
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", .revision("1e4f51c92d7ca486242d8bf0722b99de2c3531aa")) // Nov 27, 2021
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
