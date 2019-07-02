// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "AppNef", targets: ["AppNef", "Markup"]),
    ],
    targets: [
        .target(name: "Markup", path: "lib/Markup"),
        .testTarget(name: "MarkupTests", path: "lib/MarkupTests"),
        .target(name: "Common", dependencies: [], path: "core/Common"),

        .target(name: "NefCarbon", dependencies: ["Markup", "Common"], path: "core/NefCarbon"),
        .target(name: "AppNef", dependencies: ["NefCarbon", "Markup"], path: "core/AppNef"),

        .target(name: "Markdown", dependencies: ["Markup", "Common"], path: "core/Markdown"),
        .target(name: "Jekyll", dependencies: ["Markup", "Common"], path: "core/Jekyll"),
        .target(name: "Carbon", dependencies: ["NefCarbon"], path: "core/Carbon"),
    ]
)
