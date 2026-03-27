import SwiftUI

struct ToastOverlay: View {
    @Environment(ToastService.self) private var toastService

    var body: some View {
        VStack {
            if let toast = toastService.currentToast {
                HStack(spacing: 8) {
                    Image(systemName: toast.type.icon)
                        .foregroundStyle(toast.type.color)

                    Text(toast.message)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    toastService.dismiss()
                }
            }

            Spacer()
        }
        .padding(.top, 8)
        .animation(.spring(duration: 0.3), value: toastService.currentToast?.id)
    }
}

extension ToastType {
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }
}
