import SwiftUI
import Sentry


@main
struct DayreadApp: App {
    @State private var authService = AuthService()
    @State private var apiClient = APIClient()
    @State private var userService: UserService
    @State private var preferencesService: PreferencesService
    @State private var libraryService: LibraryService
    @State private var toastService = ToastService()
    @State private var ttsService = TTSService()
    @State private var studyProgressService = StudyProgressService()
    @State private var subscriptionService = SubscriptionService()
    @State private var srsService = SRSService()
    @State private var bundledSessionStore = BundledSessionStore()
    @State private var networkMonitor = NetworkMonitor()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        SentrySDK.start { options in
            options.dsn = "https://b6ef1117199547ed31229f9a2f6b5ab3@o4511134087512064.ingest.us.sentry.io/4511134090919936"

            // Adds IP for users.
            // For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
            options.sendDefaultPii = true

            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0

            // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
            options.configureProfiling = {
                $0.sessionSampleRate = 1.0 // We recommend adjusting this value in production.
                $0.lifecycle = .trace
            }

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
            
            // Enable experimental logging features
            options.experimental.enableLogs = true
        }
        // Remove the next line after confirming that your Sentry integration is working.
        SentrySDK.capture(message: "This app uses Sentry! :)")

        let api = APIClient()
        let bundled = BundledSessionStore()
        _apiClient = State(initialValue: api)
        _bundledSessionStore = State(initialValue: bundled)
        _userService = State(initialValue: UserService(apiClient: api))
        _preferencesService = State(initialValue: PreferencesService(apiClient: api))
        _libraryService = State(initialValue: LibraryService(apiClient: api, bundledStore: bundled))
    }

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                RootView()
                ToastOverlay()
            }
            .environment(authService)
            .environment(apiClient)
            .environment(userService)
            .environment(preferencesService)
            .environment(libraryService)
            .environment(toastService)
            .environment(ttsService)
            .environment(studyProgressService)
            .environment(subscriptionService)
            .environment(srsService)
            .environment(bundledSessionStore)
            .environment(networkMonitor)
            .task {
                apiClient.configure(authService: authService)
                ttsService.configure(apiClient: apiClient)
                subscriptionService.configure(apiKey: AppConstants.RevenueCat.apiKey)
                HapticsService.shared.configure(enabled: preferencesService.preferences.hapticsEnabled)
                AnalyticsService.configure(
                    sentryDsn: AppConstants.Sentry.dsn,
                    mixpanelToken: AppConstants.Mixpanel.token
                )
                AnalyticsService.track("app_launched")
                authService.start()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    Task { await libraryService.flushPendingProgress() }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
                Task {
                    try? await authService.signOut()
                    toastService.showError("세션이 만료되었습니다. 다시 로그인해주세요.")
                }
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .preferredColorScheme(colorScheme)
        }
    }

    private var colorScheme: ColorScheme? {
        switch preferencesService.preferences.theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    private func handleDeepLink(_ url: URL) {
        // dayread://session/{sessionId}
        guard url.scheme == "dayread" else { return }
        let host = url.host()
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "session":
            if let sessionId = pathComponents.first {
                NotificationCenter.default.post(
                    name: .deepLinkSession,
                    object: nil,
                    userInfo: ["sessionId": sessionId]
                )
            }
        default:
            break
        }
    }
}

// MARK: - Root View (Auth Router)

struct RootView: View {
    @Environment(AuthService.self) private var authService
    @Environment(UserService.self) private var userService
    @Environment(PreferencesService.self) private var preferencesService
    @Environment(SubscriptionService.self) private var subscriptionService

    var body: some View {
        Group {
            switch authService.state {
            case .loading:
                SplashView()

            case .unauthenticated:
                LoginView()

            case .guest:
                MainTabView()

            case .authenticated:
                if !preferencesService.preferences.onboardingComplete {
                    OnboardingView()
                } else {
                    MainTabView()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authStateKey)
        .onChange(of: authStateKey) { _, newValue in
            if newValue == "authenticated" {
                Task {
                    await userService.loadProfile()
                    await preferencesService.load()
                    if case .authenticated(let userId) = authService.state {
                        try? await subscriptionService.login(appUserID: userId)
                        AnalyticsService.identify(userId: userId)
                        AnalyticsService.track("login_success")
                    }
                    // Sync notification schedule on login
                    let prefs = preferencesService.preferences
                    await NotificationService.rescheduleIfNeeded(
                        enabled: prefs.pushNotificationsEnabled,
                        hour: prefs.notificationHour
                    )
                }
            } else if newValue == "guest" {
                userService.clearProfile()
                Task { try? await subscriptionService.logout() }
                AnalyticsService.reset()
                AnalyticsService.track("guest_started")
            } else if newValue == "unauthenticated" {
                userService.clearProfile()
                Task { try? await subscriptionService.logout() }
                AnalyticsService.reset()
            }
        }
    }

    private var authStateKey: String {
        switch authService.state {
        case .loading: return "loading"
        case .authenticated: return "authenticated"
        case .guest: return "guest"
        case .unauthenticated: return "unauthenticated"
        }
    }
}
