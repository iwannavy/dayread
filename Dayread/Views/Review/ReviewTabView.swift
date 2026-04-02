import SwiftUI

struct ReviewTabView: View {
    @Environment(SRSService.self) private var srsService

    @State private var selectedFilter: ReviewFilter = .all
    @State private var showArchived = false

    enum ReviewFilter: String, CaseIterable {
        case all = "전체"
        case sentence = "문장"
        case expression = "표현"
        case vocabulary = "단어"

        var itemType: SRSItemType? {
            switch self {
            case .all: return nil
            case .sentence: return .sentence
            case .expression: return .expression
            case .vocabulary: return .vocabulary
            }
        }
    }

    private var activeItems: [SRSItem] {
        let items = srsService.getActiveItems()
        if let type = selectedFilter.itemType {
            return items.filter { $0.type == type }
        }
        return items
    }

    private var dueItems: [SRSItem] {
        activeItems.filter { SRSAlgorithm.isDue($0) }
    }

    private var upcomingItems: [SRSItem] {
        activeItems.filter { !SRSAlgorithm.isDue($0) }
    }

    private var archivedItems: [SRSItem] {
        let items = srsService.getArchivedItems()
        if let type = selectedFilter.itemType {
            return items.filter { $0.type == type }
        }
        return items
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats summary
                statsCard

                // Filter
                filterPicker

                // Due items
                if !dueItems.isEmpty {
                    reviewSection
                }

                // Active items list
                if !upcomingItems.isEmpty {
                    itemListSection(title: "학습 중", items: upcomingItems)
                }

                // Archived
                if !archivedItems.isEmpty {
                    archivedSection
                }

                // Empty state
                if activeItems.isEmpty && archivedItems.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle("복습")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        let stats = srsService.getStats()
        return HStack(spacing: 0) {
            statItem(value: stats.due, label: "복습 대기", color: Color.dayreadGold)
            Divider().frame(height: 32)
            statItem(value: stats.learning, label: "학습 중", color: .blue)
            Divider().frame(height: 32)
            statItem(value: stats.mature, label: "숙달", color: .green)
            Divider().frame(height: 32)
            statItem(value: stats.archived, label: "완료", color: .secondary)
        }
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func statItem(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Filter

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReviewFilter.allCases, id: \.self) { filter in
                    let isSelected = selectedFilter == filter
                    let count = countForFilter(filter)
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(filter.rawValue)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(isSelected ? Color.white.opacity(0.3) : Color(.tertiarySystemFill), in: Capsule())
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .background(isSelected ? Color.dayreadGold : Color(.secondarySystemGroupedBackground), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func countForFilter(_ filter: ReviewFilter) -> Int {
        if let type = filter.itemType {
            return srsService.getActiveItems().filter { $0.type == type }.count
        }
        return srsService.getActiveItems().count
    }

    // MARK: - Review Section

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("복습 대기")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    FlashcardReviewView()
                } label: {
                    HStack(spacing: 4) {
                        Text("복습 시작")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.dayreadGold, in: Capsule())
                }
            }

            ForEach(dueItems) { item in
                ReviewItemRow(item: item)
            }
        }
    }

    // MARK: - Item List

    private func itemListSection(title: String, items: [SRSItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            ForEach(items) { item in
                ReviewItemRow(item: item)
            }
        }
    }

    // MARK: - Archived

    private var archivedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation { showArchived.toggle() }
            } label: {
                HStack {
                    Text("완료")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(archivedItems.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(showArchived ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if showArchived {
                ForEach(archivedItems) { item in
                    ReviewItemRow(item: item, isArchived: true) {
                        srsService.unarchiveItem(id: item.id)
                    }
                }
            }
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)

            Text("저장된 항목이 없습니다")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Text("학습 중 문장, 표현, 단어 옆의\n+ 버튼을 눌러 복습에 추가하세요")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Review Item Row

private struct ReviewItemRow: View {
    let item: SRSItem
    var isArchived = false
    var onUnarchive: (() -> Void)? = nil

    @Environment(SRSService.self) private var srsService

    var body: some View {
        HStack(spacing: 12) {
            // Type badge
            Text(item.type.displayName)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(item.type.badgeColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
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

            // Level / schedule indicator
            if isArchived {
                if let onUnarchive {
                    Button {
                        onUnarchive()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                levelBadge
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                srsService.removeItem(id: item.id)
            } label: {
                Label("삭제", systemImage: "trash")
            }

            if !isArchived {
                Button {
                    srsService.archiveItem(id: item.id)
                } label: {
                    Label("완료", systemImage: "checkmark.circle")
                }
                .tint(.green)
            }
        }
    }

    private var levelBadge: some View {
        let intervals = SRSAlgorithm.fixedIntervals
        let level = item.level
        let isDue = SRSAlgorithm.isDue(item)

        return HStack(spacing: 3) {
            ForEach(0..<intervals.count, id: \.self) { i in
                Circle()
                    .fill(i < level ? Color.dayreadGold : Color(.tertiarySystemFill))
                    .frame(width: 5, height: 5)
            }

            if isDue {
                Text("복습")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.dayreadGold)
            } else {
                Text(item.nextIntervalLabel)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
