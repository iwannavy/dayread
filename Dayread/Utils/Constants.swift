import Foundation

enum AppConstants {
    static let appId = "com.dayread.app"
    static let appName = "데일리딩"

    enum API {
        #if DEBUG
        static let baseURL = URL(string: "https://dayread.day")!
        #else
        static let baseURL = URL(string: "https://dayread.day")!
        #endif

        static func url(_ path: String) -> URL {
            baseURL.appendingPathComponent(path)
        }
    }

    enum Supabase {
        static let url = URL(string: "https://iqekgslbraacznmdiore.supabase.co")!
        static let anonKey = bundleString("SUPABASE_ANON_KEY")
    }

    enum RevenueCat {
        static let apiKey = bundleString("REVENUECAT_API_KEY")
    }

    enum Sentry {
        static let dsn = bundleString("SENTRY_DSN")
    }

    enum Mixpanel {
        static let token = bundleString("MIXPANEL_TOKEN")
    }

    /// Read a string from Info.plist (injected via xcconfig or build settings)
    private static func bundleString(_ key: String) -> String {
        Bundle.main.infoDictionary?[key] as? String ?? ""
    }
}
