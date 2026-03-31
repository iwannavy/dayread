// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Dayread",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Dayread", targets: ["Dayread"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm.git", from: "5.0.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", from: "8.0.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift.git", from: "4.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "Dayread",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
                .product(name: "Sentry", package: "sentry-cocoa"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ],
            path: "."
        ),
    ]
)
