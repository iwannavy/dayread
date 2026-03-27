import Foundation

@Observable
final class PreferencesService {
    private(set) var preferences: AppPreferences = .default
    private(set) var isLoaded = false

    private let apiClient: APIClient
    private var saveTask: Task<Void, Never>?
    private static let cacheKey = "dayread-preferences"

    init(apiClient: APIClient) {
        self.apiClient = apiClient
        restoreFromDiskCache()
    }

    func load() async {
        do {
            let response = try await apiClient.fetchPreferences()
            preferences = AppPreferences.normalized(from: response.preferences)
            isLoaded = true
            persistToDiskCache()
        } catch {
            isLoaded = true // Use defaults (or cached values) on error
        }
    }

    // MARK: - Disk Cache

    private func restoreFromDiskCache() {
        if let data = UserDefaults.standard.data(forKey: Self.cacheKey),
           let cached = try? JSONDecoder().decode(AppPreferences.self, from: data) {
            preferences = AppPreferences.normalized(from: cached)
        }
    }

    private func persistToDiskCache() {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: Self.cacheKey)
        }
    }

    func updatePreferences(_ patch: AppPreferences) {
        preferences = AppPreferences.normalized(from: patch)
        persistToDiskCache()
        debouncedSave()
    }

    func setAutoplayAudio(_ value: Bool) {
        preferences.autoplayAudio = value
        debouncedSave()
    }

    func setPlaybackRate(_ rate: Double) {
        preferences.defaultPlaybackRate = min(2.0, max(0.5, (rate * 4).rounded() / 4))
        debouncedSave()
    }

    func setTheme(_ theme: ThemePreference) {
        preferences.theme = theme
        debouncedSave()
    }

    func setTextScale(_ scale: TextScale) {
        preferences.textScale = scale
        debouncedSave()
    }

    func setFontStyle(_ style: FontStyle) {
        preferences.fontStyle = style
        debouncedSave()
    }

    func setHapticsEnabled(_ enabled: Bool) {
        preferences.hapticsEnabled = enabled
        debouncedSave()
    }

    func setPushNotifications(enabled: Bool, hour: Int? = nil) {
        preferences.pushNotificationsEnabled = enabled
        if let hour {
            preferences.notificationHour = max(0, min(23, hour))
        }
        debouncedSave()
    }

    func setOnboardingComplete() {
        preferences.onboardingComplete = true
        debouncedSave()
    }

    // MARK: - Debounced Save

    private func debouncedSave() {
        persistToDiskCache()
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled, let self else { return }
            _ = try? await self.apiClient.updatePreferences(self.preferences)
        }
    }
}
