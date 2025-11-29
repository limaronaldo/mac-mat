// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MacMaintenance",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        . executable(name: "mac-maint", targets: ["MacMaintenance"])
    ],
    dependencies: [],
    targets: [
        . executableTarget(
            name: "MacMaintenance",
            dependencies: [],
            path: "Sources/MacMaintenance"
        )
    ]
)