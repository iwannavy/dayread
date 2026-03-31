import UIKit

final class HapticsService {
    static let shared = HapticsService()

    private var isEnabled = true

    func configure(enabled: Bool) {
        isEnabled = enabled
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // Convenience methods matching current Capacitor haptics usage
    func tap() { impact(.light) }
    func soft() { impact(.soft) }
    func light() { impact(.light) }
    func medium() { impact(.medium) }
    func success() { notification(.success) }
    func error() { notification(.error) }
    func warning() { notification(.warning) }
}
