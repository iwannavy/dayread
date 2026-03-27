import SwiftUI

struct PremiumBadge: View {
    var text: String = "Premium"
    var compact = false

    var body: some View {
        Text(text)
            .font(compact ? .caption2 : .caption)
            .fontWeight(.medium)
            .foregroundStyle(Color.dayreadGold)
            .padding(.horizontal, compact ? 6 : 8)
            .padding(.vertical, compact ? 2 : 3)
            .background(
                Capsule()
                    .fill(Color.dayreadGold.opacity(0.12))
            )
    }
}

struct LockedOverlay: View {
    let reason: String?

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.title3)
                .foregroundStyle(Color.dayreadGold)

            if let reason {
                Text(reason)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
