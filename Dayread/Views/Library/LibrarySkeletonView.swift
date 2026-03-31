import SwiftUI

struct LibrarySkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Week Header Skeleton
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 60, height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 140, height: 24)
            }
            .shimmer()

            // Session List Skeleton
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    sessionItemSkeleton
                }
            }
        }
        .padding(.horizontal)
    }

    private var sessionItemSkeleton: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 18)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 200, height: 14)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shimmer()
    }
}
