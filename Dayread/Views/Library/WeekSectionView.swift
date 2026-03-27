import SwiftUI

struct WeekSectionView: View {
    let weekNumber: Int
    let weekMeta: CurriculumUtils.CurriculumWeekMeta
    let sessions: [StudySessionListItem]
    let membershipTier: MembershipTier
    let isFreeWeek: Bool
    let onSessionTap: (StudySessionListItem) -> Void
    var onSessionAppear: ((String) -> Void)?

    private var weekProgressPercent: Double {
        guard !sessions.isEmpty else { return 0 }
        let totalSentences = sessions.reduce(0) { $0 + $1.overview.sentenceCount }
        guard totalSentences > 0 else { return 0 }
        let studiedSentences = sessions.reduce(0) { sum, session in
            sum + (session.progress?.studiedSentences.count ?? 0)
        }
        return Double(studiedSentences) / Double(totalSentences) * 100
    }

    private var isLocked: Bool {
        !isFreeWeek && membershipTier != .premium
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            weekHeader
            sessionsList
        }
        .padding(.vertical, 4)
        .opacity(isLocked ? 0.6 : 1)
    }

    private var weekHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("Week \(weekNumber)")
                    .font(.headline)

                Text(CurriculumUtils.difficultyLabel(weekMeta.difficulty))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(CurriculumUtils.difficultyColor(weekMeta.difficulty))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(CurriculumUtils.difficultyColor(weekMeta.difficulty).opacity(0.12))
                    )

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(Color.dayreadGold)
                }

                Spacer()

                if weekProgressPercent > 0 {
                    Text("\(Int(weekProgressPercent))%")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(weekProgressPercent >= 100 ? .green : Color.dayreadGold)
                }
            }

            Text(weekMeta.themeKo)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    private var sessionsList: some View {
        VStack(spacing: 4) {
            ForEach(sessions) { session in
                SessionListItemView(
                    session: session,
                    membershipTier: membershipTier,
                    onTap: { onSessionTap(session) },
                    onAppear: { onSessionAppear?(session.id) }
                )
            }
        }
    }
}
