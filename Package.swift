// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scheme",
    products: [
        .executable(name: "Scheme_Terminal", targets: ["Scheme"]),
        .library(name: "Scheme", targets: ["Scheme"]),
           ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Scheme",
            dependencies: [],
            resources: [
                .copy("Resources/init.scm")
            ])
    ]
)
