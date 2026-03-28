import SwiftUI

struct DailyEditionCard: View {
    let edition: DailyNewsEdition?
    var isLoading = false
    var onTap: ((String) -> Void)?

    var body: some View {
        if isLoading {
            loadingState
        } else if let edition {
            Button {
                if let sessionId = edition.sessionId {
                    onTap?(sessionId)
                }
            } label: {
                editionCard(edition)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("오늘의 에디션: \(edition.subjectLine)")
            .accessibilityHint(edition.sessionId != nil ? "탭하여 오늘의 브리핑 열기" : "")
        }
    }

    private var loadingState: some View {
        HStack {
            ProgressView()
                .controlSize(.small)
            Text("오늘의 에디션 불러오는 중...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    private func editionCard(_ edition: DailyNewsEdition) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("오늘의 에디션")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.dayreadGold)

                Spacer()

                Text(formatEditionDate(edition.editionDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(edition.subjectLine)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)

            if !edition.introKo.isEmpty {
                Text(edition.introKo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if edition.sessionId != nil {
                Text("오늘의 3문장 브리핑 열기 \(Image(systemName: "arrow.right"))")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.dayreadGold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.dayreadGold.opacity(0.08))
                .strokeBorder(Color.dayreadGold.opacity(0.2), lineWidth: 1)
        )
    }

    private func formatEditionDate(_ dateStr: String) -> String {
        guard let date = DateFormatters.parseISO(dateStr)
                ?? DateFormatters.shortDate.date(from: dateStr) else {
            return dateStr
        }
        return DateFormatters.displayDate.string(from: date)
    }
}
