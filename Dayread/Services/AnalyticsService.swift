import Foundation
import Sentry
import Mixpanel

/// Unified analytics wrapper for Sentry (crash reporting) + Mixpanel (event tracking)
/// Port of src/lib/analytics.ts
enum AnalyticsService {
    private static var isConfigured = false

    // MARK: - Setup

    static func configure(sentryDsn: String, mixpanelToken: String) {
        guard !isConfigured else { return }

        // Sentry
        if !sentryDsn.isEmpty {
            SentrySDK.start { options in
                options.dsn = sentryDsn
                options.tracesSampleRate = 0.2
                options.enableAutoSessionTracking = true
                #if DEBUG
                options.enabled = false
                #endif
            }
        }

        // Mixpanel
        if !mixpanelToken.isEmpty {
            Mixpanel.initialize(token: mixpanelToken, trackAutomaticEvents: true)
            Mixpanel.mainInstance().people.set(properties: ["platform": "iOS"])
            print("[Analytics] Mixpanel initialized with token: \(mixpanelToken.prefix(8))...")
        } else {
            print("[Analytics] Mixpanel token is EMPTY — skipped")
        }

        isConfigured = true
    }

    // MARK: - User Identity

    static func identify(userId: String) {
        #if DEBUG
        print("[Analytics] identify: \(userId)")
        #endif
        SentrySDK.setUser(User(userId: userId))
        Mixpanel.mainInstance().identify(distinctId: userId)
        Mixpanel.mainInstance().people.set(properties: [
            "$name": userId,
            "platform": "iOS"
        ])
        Mixpanel.mainInstance().flush()
    }

    static func reset() {
        #if DEBUG
        print("[Analytics] reset")
        #else
        SentrySDK.setUser(nil)
        Mixpanel.mainInstance().reset()
        #endif
    }

    // MARK: - Error Capture

    static func captureError(_ error: Error, context: String? = nil) {
        #if DEBUG
        print("[Analytics] error: \(context ?? "") \(error)")
        #else
        SentrySDK.capture(error: error) { scope in
            if let context {
                scope.setContext(value: ["info": context], key: "dayread")
            }
        }
        #endif
    }

    // MARK: - Event Tracking

    static func track(_ event: String, properties: [String: MixpanelType]? = nil) {
        #if DEBUG
        if let properties {
            print("[Analytics] \(event) \(properties)")
        } else {
            print("[Analytics] \(event)")
        }
        #endif
        SentrySDK.addBreadcrumb(Breadcrumb(level: .info, category: "analytics"))
        Mixpanel.mainInstance().track(event: event, properties: properties)
        Mixpanel.mainInstance().flush()
    }
}
