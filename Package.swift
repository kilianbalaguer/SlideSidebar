// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SlideSidebar",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SlideSidebar",
            targets: ["SlideSidebar"]
        )
    ],
    targets: [
        .target(
            name: "SlideSidebar"
        )
    ]
)
