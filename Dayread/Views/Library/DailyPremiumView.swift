import SwiftUI

struct DailyPremiumView: View {
    @Environment(LibraryService.self) private var libraryService

    let onSessionTap: (String) -> Void
    let onShowPaywall: () -> Void

    private var membershipTier: MembershipTier {
        libraryService.membershipTier
    }

    private var sessionMap: [String: StudySessionListItem] {
        Dictionary(uniqueKeysWithValues: libraryService.hydratedSessions.map { ($0.id, $0) })
    }

    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(PremiumContent.groupedByDate, id: \.date) { group in
                dateSection(date: group.date, items: group.items)
            }
        }
    }

    // MARK: - Date Section

    private func dateSection(date: String, items: [PremiumContentItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Date header
            Text(formatDate(date))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.dayreadGold)
                .padding(.bottom, 2)

            ForEach(items) { item in
                premiumItemRow(item)
            }
        }
    }

    // MARK: - Item Row

    private func premiumItemRow(_ item: PremiumContentItem) -> some View {
        Button {
            if let sessionId = item.sessionId, sessionMap[sessionId] != nil {
                if membershipTier == .premium {
                    onSessionTap(sessionId)
                } else {
                    onShowPaywall()
                }
            } else {
                // Session not yet processed — show paywall or do nothing
                if membershipTier != .premium {
                    onShowPaywall()
                }
            }
        } label: {
            HStack(spacing: 12) {
                // Difficulty indicator
                Text("Lv.\(item.difficulty)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CurriculumUtils.difficultyColor(item.difficulty))
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(CurriculumUtils.difficultyColor(item.difficulty).opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text("Dayread Original")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                if membershipTier != .premium {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.dayreadGold)
                } else if item.sessionId != nil, sessionMap[item.sessionId!] != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(StudyLayout.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusMD)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Formatting

    private func formatDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
