// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "RSConfettiView",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RSConfettiView",
            targets: ["RSConfettiView"]
        ),
    ],
    targets: [
        .target(
            name: "RSConfettiView",
            path: "Sources"
        ),
        .testTarget(
            name: "RSConfettiViewTests",
            dependencies: ["RSConfettiView"]
        ),
    ]
)
