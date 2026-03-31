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
        VStack(alignment: .leading, spacing: 20) {
            weekHeader
            sessionsList
        }
        .padding(.vertical, 12)
        .opacity(isLocked ? 0.7 : 1)
    }

    private var weekHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("Week \(weekNumber)")
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.bold)
                
                Text(weekMeta.themeKo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(Color.dayreadGold)
                }
            }

            // Week Progress Gauge
            if !isLocked && weekProgressPercent > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Weekly Progress")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text("\(Int(weekProgressPercent))%")
                            .font(.system(size: 10, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(weekProgressPercent >= 100 ? .green : Color.dayreadGold)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.secondarySystemBackground))
                            Capsule()
                                .fill(weekProgressPercent >= 100 ? Color.green.opacity(0.6) : Color.dayreadGold.opacity(0.6))
                                .frame(width: geo.size.width * CGFloat(weekProgressPercent) / 100)
                        }
                    }
                    .frame(height: 4)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private var sessionsList: some View {
        ZStack(alignment: .leading) {
            // Connecting Line
            if sessions.count > 1 {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 2)
                    .padding(.leading, 26) // Centered under the 44pt circle (4+44/2 = 26)
                    .padding(.vertical, 20)
            }

            VStack(spacing: 12) {
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
}
