import SwiftUI

/// Curriculum visualization — 3 months × 4 weeks × 4 sessions
/// Port of src/components/progress/ProgressMap.tsx
struct CurriculumMapView: View {
    @Environment(LibraryService.self) private var libraryService

    @State private var expandedWeek: Int? = nil

    private var sessions: [StudySessionListItem] { libraryService.sessions }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(CurriculumUtils.months, id: \.month) { month in
                    monthCard(month)
                }
            }
            .padding()
        }
    }

    // MARK: - Month Card

    private func monthCard(_ month: CurriculumUtils.CurriculumMonth) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month header
            VStack(alignment: .leading, spacing: 4) {
                Text("\(month.month)월")
                    .font(.caption2)
                    .tracking(1)
                    .foregroundStyle(.tertiary)

                Text("\(month.titleKo) · \(month.title)")
                    .font(.headline)
            }

            // Week timeline
            HStack(spacing: 8) {
                ForEach(month.weeks, id: \.week) { week in
                    weekTile(week)
                }
            }

            // Expanded week detail
            if let expandedWeek, month.weeks.contains(where: { $0.week == expandedWeek }) {
                if let weekMeta = CurriculumUtils.getWeekData(expandedWeek) {
                    weekDetail(weekMeta)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            // Milestones
            if !month.milestones.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(Array(month.milestones.enumerated()), id: \.offset) { _, milestone in
                        Text(milestone)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.dayreadGold.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Week Tile

    private func weekTile(_ week: CurriculumUtils.CurriculumWeekMeta) -> some View {
        let isExpanded = expandedWeek == week.week
        let completion = weekCompletion(week.week)
        let isComplete = completion >= 1.0
        let isFree = week.week <= CurriculumContent.freeWeekLimit

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                expandedWeek = isExpanded ? nil : week.week
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(tileColor(isExpanded: isExpanded, isComplete: isComplete))
                        .frame(width: 44, height: 44)

                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    } else {
                        Text("W\(week.week)")
                            .font(.caption2.bold())
                            .foregroundStyle(isExpanded ? .white : .primary)
                    }
                }

                Text(week.themeKo)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.gray.opacity(0.2))
                        Capsule().fill(isComplete ? .green : Color.dayreadGold)
                            .frame(width: geo.size.width * completion)
                    }
                }
                .frame(height: 3)

                if !isFree {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(.tertiary)
                } else {
                    Color.clear.frame(height: 10)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(week.week)주차 \(week.themeKo)")
        .accessibilityValue("완료율 \(Int(completion * 100))%\(isFree ? "" : ", 프리미엄")")
    }

    private func tileColor(isExpanded: Bool, isComplete: Bool) -> Color {
        if isComplete { return .green }
        if isExpanded { return Color.dayreadGold }
        return Color.gray.opacity(0.15)
    }

    // MARK: - Week Detail (Expanded)

    private func weekDetail(_ week: CurriculumUtils.CurriculumWeekMeta) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Theme + Focus tags
            VStack(alignment: .leading, spacing: 8) {
                Text(week.themeKo)
                    .font(.subheadline.bold())

                FlowLayout(spacing: 6) {
                    ForEach(week.focus, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(CurriculumUtils.difficultyColor(week.difficulty).opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }

            Divider()

            // Content items
            let items = CurriculumContent.weekContent[week.week] ?? []
            ForEach(items) { item in
                contentItemRow(item)
            }
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Content Item Row

    private func contentItemRow(_ item: CurriculumContentItem) -> some View {
        let session = findSession(for: item)
        let progress = sessionProgress(for: item)

        return HStack(spacing: 10) {
            Image(systemName: CurriculumUtils.genreIcon(item.genre))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.caption)
                    .lineLimit(1)

                Text(item.source)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if session != nil {
                if progress > 0 {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(progress >= 1.0 ? .green : Color.dayreadGold)
                } else {
                    Text("미시작")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func weekCompletion(_ weekNumber: Int) -> Double {
        let items = CurriculumContent.weekContent[weekNumber] ?? []
        guard !items.isEmpty else { return 0 }

        let completedCount = items.filter { item in
            guard let sessionId = item.sessionId else { return false }
            guard let session = sessions.first(where: { $0.id == sessionId }) else { return false }
            return sessionCompletionRatio(session) >= 1.0
        }.count

        return Double(completedCount) / Double(items.count)
    }

    private func findSession(for item: CurriculumContentItem) -> StudySessionListItem? {
        guard let sessionId = item.sessionId else { return nil }
        return sessions.first { $0.id == sessionId }
    }

    private func sessionProgress(for item: CurriculumContentItem) -> Double {
        guard let session = findSession(for: item) else { return 0 }
        return sessionCompletionRatio(session)
    }

    private func sessionCompletionRatio(_ session: StudySessionListItem) -> Double {
        let total = session.overview.sentenceCount
        guard total > 0 else { return 0 }
        let studied = session.progressState?.studiedSentenceIds.count ?? 0
        return min(1.0, Double(studied) / Double(total))
    }
}
