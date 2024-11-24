// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "autologin_darwin",
    platforms: [
        .iOS("11.0"),
        .macOS("11.0")
    ],
    products: [
        .library(name: "plugin-name", targets: ["autologin-darwin"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "autologin_darwin",
            dependencies: [],
            resources: [
                // Hint: If your plugin requires a privacy manifest
                // (e.g. if it uses any required reason APIs), update the PrivacyInfo.xcprivacy file
                // to describe your plugin's privacy impact, and then uncomment this line.
                // For more information, see:
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),

                // Hint: If you have other resources that need to be bundled with your plugin, refer to
                // the following instructions to add them:
                // https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package
            ]
        )
    ]
)
