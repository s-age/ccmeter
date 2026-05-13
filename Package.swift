// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CCMeter",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CCMeter",
            path: "Sources/CCMeter",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Resources/Info.plist",
                ])
            ]
        ),
        .testTarget(
            name: "CCMeterTests",
            dependencies: ["CCMeter"],
            path: "Tests"
        )
    ]
)
