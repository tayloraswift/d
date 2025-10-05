// swift-tools-version:6.1
import PackageDescription

let package: Package = .init(
    name: "d",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "D", targets: ["D"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
        .package(url: "https://github.com/tayloraswift/dollup", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "D",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
            ],
        ),
        .testTarget(
            name: "DTests",
            dependencies: [
                .target(name: "D"),
            ]
        ),
    ]
)

for target: Target in package.targets {
    {
        $0 = ($0 ?? []) + [
            .enableUpcomingFeature("ExistentialAny")
        ]
    }(&target.swiftSettings)
}
