import Foundation

enum ThemePreference: String, Codable {
    case system, light, dark
}

enum TextScale: String, Codable {
    case compact, `default`, large
}

enum FontStyle: String, Codable {
    case sans, serif
}

enum StudyPhase: String, Codable {
    case immersive, focus, overview
}

struct AppPreferences: Codable {
    var autoplayAudio: Bool
    var defaultPlaybackRate: Double
    var pushNotificationsEnabled: Bool
    var notificationHour: Int
    var hapticsEnabled: Bool
    var adminMembershipPreview: AdminMembershipPreview
    var theme: ThemePreference
    var textScale: TextScale
    var fontStyle: FontStyle
    var studySequence: [StudyPhase]
    var onboardingComplete: Bool

    static let `default` = AppPreferences(
        autoplayAudio: false,
        defaultPlaybackRate: 1.0,
        pushNotificationsEnabled: false,
        notificationHour: 9,
        hapticsEnabled: true,
        adminMembershipPreview: .base,
        theme: .system,
        textScale: .default,
        fontStyle: .sans,
        studySequence: [.immersive, .focus, .overview],
        onboardingComplete: false
    )

    static func normalized(from raw: AppPreferences?) -> AppPreferences {
        guard let raw else { return .default }
        return AppPreferences(
            autoplayAudio: raw.autoplayAudio,
            defaultPlaybackRate: min(2.0, max(0.5, (raw.defaultPlaybackRate * 4).rounded() / 4)),
            pushNotificationsEnabled: raw.pushNotificationsEnabled,
            notificationHour: max(0, min(23, raw.notificationHour)),
            hapticsEnabled: raw.hapticsEnabled,
            adminMembershipPreview: raw.adminMembershipPreview,
            theme: raw.theme,
            textScale: raw.textScale,
            fontStyle: raw.fontStyle,
            studySequence: raw.studySequence.isEmpty ? AppPreferences.default.studySequence : raw.studySequence,
            onboardingComplete: raw.onboardingComplete
        )
    }
}
