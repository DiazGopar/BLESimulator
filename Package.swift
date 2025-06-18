// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BLESimulator",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "BLESimulator",
            targets: ["BLESimulator"]
        )
    ],
    dependencies: [
        // Add any external dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "BLESimulator",
            dependencies: [],
            path: "Sources",
            sources: [
                "BLESimulator/BLESimulatorApp.swift",
                "BLESimulator/BLEPeripheralManager.swift",
                "Views/ContentView.swift",
                "Views/DeviceConfigurationView.swift",
                "Models/DeviceConfigurationModels.swift"
            ],
            resources: [
                .copy("../ConfigurationExamples")
            ]
        )
    ]
)
