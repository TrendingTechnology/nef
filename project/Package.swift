// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef-bin",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "nef-markdown-page", targets: ["MarkdownPage"]),
        .executable(name: "nef-jekyll-page", targets: ["JekyllPage"]),
        .executable(name: "nef-carbon-page", targets: ["CarbonPage"]),
        .executable(name: "nef-playground-book", targets: ["PlaygroundBook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bow-swift/bow", .exact("0.7.0")),
        .package(url: "https://github.com/bow-swift/Swiftline", .exact("0.5.4")),
    ],
    targets: [
        .target(name: "NefCommon", path: "Component/NefCommon", publicHeadersPath: "Support Files"),
        .target(name: "NefModels", dependencies: ["BowEffects"], path: "Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefModels"], path: "Core", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefCore"], path: "Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefCore"], path: "Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefCore", "NefCommon"], path: "Component/NefCarbon", publicHeadersPath: "Support Files"),
        .target(name: "NefSwiftPlayground", dependencies: ["Bow", "BowEffects", "BowOptics", "NefModels", "NefCommon"], path: "Component/NefSwiftPlayground", publicHeadersPath: "Support Files"),


        .target(name: "nef", dependencies: ["Bow", "BowEffects", "Swiftline",
                                            "NefCommon",
                                            "NefModels",
                                            "NefCore",
                                            "NefMarkdown",
                                            "NefJekyll",
                                            "NefCarbon",
                                            "NefSwiftPlayground"], path: "Component/nef", publicHeadersPath: "Support Files"),
        .target(name: "CLIKit", dependencies: ["Bow", "BowEffects", "nef"], path: "UI/CLIKit", publicHeadersPath: "Support Files"),

        .target(name: "MarkdownPage",   dependencies: ["Bow", "BowEffects", "CLIKit", "NefMarkdown"], path: "UI/MarkdownPage"),
        .target(name: "JekyllPage",     dependencies: ["Bow", "BowEffects", "CLIKit", "NefJekyll"], path: "UI/JekyllPage"),
        .target(name: "CarbonPage",     dependencies: ["Bow", "BowEffects", "CLIKit", "NefCarbon"], path: "UI/CarbonPage"),
        .target(name: "PlaygroundBook", dependencies: ["CLIKit", "nef"], path: "UI/PlaygroundBook"),
    ]
)
