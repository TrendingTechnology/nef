// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .library(name: "nef", targets: ["nef", "NefModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bow-swift/bow", .exact("0.7.0")),
        .package(url: "https://github.com/bow-swift/Swiftline", .exact("0.5.4")),
    ],
    targets: [
        .target(name: "NefCommon", dependencies: ["Bow", "BowEffects", "BowOptics"], path: "project/Component/NefCommon", publicHeadersPath: "Support Files"),
        .target(name: "NefModels", dependencies: ["BowEffects"], path: "project/Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefModels"], path: "project/Core", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefCore", "NefCommon"], path: "project/Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefCore"], path: "project/Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefCore", "NefCommon"], path: "project/Component/NefCarbon", publicHeadersPath: "Support Files"),
        .target(name: "NefSwiftPlayground", dependencies: ["NefModels", "NefCommon"], path: "project/Component/NefSwiftPlayground", publicHeadersPath: "Support Files"),

        .target(name: "nef",
                dependencies: ["Swiftline",
                               "NefCommon",
                               "NefCore",
                               "NefModels",
                               "NefMarkdown",
                               "NefJekyll",
                               "NefCarbon",
                               "NefSwiftPlayground"],
                path: "project/Component/nef",
                publicHeadersPath: "Support Files"),
    ]
)
