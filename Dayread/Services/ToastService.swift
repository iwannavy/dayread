import Foundation

enum ToastType {
    case success
    case error
    case info
}

struct ToastMessage: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastType
    let duration: TimeInterval

    init(_ message: String, type: ToastType = .info, duration: TimeInterval = 3) {
        self.message = message
        self.type = type
        self.duration = duration
    }
}

@Observable
final class ToastService {
    var currentToast: ToastMessage?
    private var dismissTask: Task<Void, Never>?

    func show(_ message: String, type: ToastType = .info, duration: TimeInterval = 3) {
        dismissTask?.cancel()
        currentToast = ToastMessage(message, type: type, duration: duration)

        dismissTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            self?.currentToast = nil
        }
    }

    func showSuccess(_ message: String) {
        show(message, type: .success)
    }

    func showError(_ message: String) {
        show(message, type: .error, duration: 5)
    }

    func dismiss() {
        dismissTask?.cancel()
        currentToast = nil
    }
}
