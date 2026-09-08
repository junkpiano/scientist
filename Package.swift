// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Scientist",
    platforms: [.macOS(.v10_13),
                .iOS(.v12),
                .tvOS(.v12),
                .watchOS(.v4)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Scientist",
            targets: ["Scientist"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages
        // which this package depends on.
        .target(
            name: "Scientist",
            dependencies: []),
        .testTarget(
            name: "ScientistTests",
            dependencies: ["Scientist"])
    ]
)

// The DocC plugin is only needed to build documentation. Adding it
// unconditionally would push it into the dependency graph of everyone who
// depends on Scientist, so it is opt-in via the environment.
if Context.environment["SCIENTIST_BUILD_DOCC"] != nil {
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ]
}
