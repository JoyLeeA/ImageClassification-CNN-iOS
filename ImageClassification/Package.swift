// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ImageClassification",
    products: [
        .library(
            name: "ImageClassification",
            targets: ["ImageClassification"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ImageClassification",
            dependencies: [],
            path: "Sources/ImageClassification"
        )
    ]
)
