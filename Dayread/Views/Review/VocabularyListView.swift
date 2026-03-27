import SwiftUI

struct VocabularyListView: View {
    @Environment(SRSService.self) private var srsService

    @State private var filterType: SRSItemType?
    @State private var showReview = false

    private var filteredItems: [SRSItem] {
        guard let filterType else { return srsService.items }
        return srsService.items.filter { $0.type == filterType }
    }

    var body: some View {
        List {
            // Stats section
            statsSection

            // Filter
            filterSection

            // Items
            if filteredItems.isEmpty {
                emptySection
            } else {
                itemsSection
            }

            // Upcoming reviews
            upcomingSection
        }
        .navigationTitle("단어장")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("복습") {
                    FlashcardReviewView()
                }
                .foregroundStyle(Color.dayreadGold)
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        let stats = srsService.getStats()
        return Section {
            HStack(spacing: 0) {
                statItem("전체", value: srsService.items.count)
                Divider().frame(height: 30)
                statItem("복습 대기", value: stats.due, highlight: stats.due > 0)
                Divider().frame(height: 30)
                statItem("학습 중", value: stats.learning)
                Divider().frame(height: 30)
                statItem("숙달", value: stats.mature)
            }
        }
    }

    private func statItem(_ label: String, value: Int, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.subheadline.bold())
                .foregroundStyle(highlight ? Color.dayreadGold : .primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Filter

    private var filterSection: some View {
        Section {
            Picker("유형", selection: $filterType) {
                Text("전체").tag(nil as SRSItemType?)
                Text("단어").tag(SRSItemType.vocabulary as SRSItemType?)
                Text("패턴").tag(SRSItemType.pattern as SRSItemType?)
                Text("표현").tag(SRSItemType.expression as SRSItemType?)
            }
            .pickerStyle(.segmented)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }

    // MARK: - Empty

    private var emptySection: some View {
        Section {
            VStack(spacing: 8) {
                Text("저장된 항목이 없습니다")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("학습 중 단어 옆의 저장 버튼을 눌러 추가하세요.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Items List

    private var itemsSection: some View {
        Section("항목 (\(filteredItems.count))") {
            ForEach(filteredItems) { item in
                HStack(spacing: 12) {
                    // Type badge
                    Text(item.type.displayName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(item.type.badgeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.type.badgeColor.opacity(0.12), in: Capsule())

                    // Content
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.front)
                            .font(.subheadline)
                            .lineLimit(1)

                        Text(item.back)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Interval
                    Text(intervalText(item))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        srsService.removeItem(id: item.id)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
    }

    // MARK: - Upcoming

    private var upcomingSection: some View {
        Section("향후 7일 복습 예정") {
            let upcoming = upcomingReviewCounts()
            if upcoming.allSatisfy({ $0.count == 0 }) {
                Text("예정된 복습이 없습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 0) {
                    ForEach(upcoming, id: \.date) { day in
                        VStack(spacing: 4) {
                            Text("\(day.count)")
                                .font(.caption.bold())
                                .foregroundStyle(day.count > 0 ? Color.dayreadGold : .secondary)

                            Text(day.label)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func intervalText(_ item: SRSItem) -> String {
        if item.repetitions == 0 { return "새 단어" }
        if item.interval == 1 { return "1일 후" }
        return "\(item.interval)일 후"
    }

    private struct UpcomingDay {
        let date: String
        let label: String
        let count: Int
    }

    private func upcomingReviewCounts() -> [UpcomingDay] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current

        let dayLabels = ["일", "월", "화", "수", "목", "금", "토"]

        return (0..<7).map { daysAhead in
            let date = calendar.date(byAdding: .day, value: daysAhead, to: Date()) ?? Date()
            let dateStr = dateFormatter.string(from: date)
            let weekday = calendar.component(.weekday, from: date) - 1

            let count = srsService.items.filter { item in
                guard let reviewDate = DateFormatters.parseISO(item.nextReview) else { return false }
                let reviewDateStr = dateFormatter.string(from: reviewDate)
                return reviewDateStr == dateStr
            }.count

            return UpcomingDay(
                date: dateStr,
                label: daysAhead == 0 ? "오늘" : dayLabels[weekday],
                count: count
            )
        }
    }
}
