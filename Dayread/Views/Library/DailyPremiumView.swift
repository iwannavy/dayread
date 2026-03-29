import SwiftUI

struct DailyPremiumView: View {
    @Environment(LibraryService.self) private var libraryService

    let onSessionTap: (String) -> Void
    let onShowPaywall: () -> Void

    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Date()

    private var membershipTier: MembershipTier {
        libraryService.membershipTier
    }

    private var sessionMap: [String: StudySessionListItem] {
        Dictionary(uniqueKeysWithValues: libraryService.hydratedSessions.map { ($0.id, $0) })
    }

    private let calendar = Calendar.current
    private let weekdayLabels = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        LazyVStack(spacing: 16) {
            calendarCard
            selectedDateContent
        }
    }

    // MARK: - Calendar Card

    private var calendarCard: some View {
        VStack(spacing: 12) {
            monthHeader
            weekdayRow
            dayGrid
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(monthYearString)
                .font(.subheadline.weight(.bold))

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Weekday Row

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(weekdayLabels, id: \.self) { label in
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Day Grid

    private var dayGrid: some View {
        let days = calendarDays()
        let rows = days.chunked(into: 7)

        return VStack(spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                        dayCell(day)
                    }
                }
            }
        }
    }

    private func dayCell(_ day: CalendarDay) -> some View {
        Button {
            if let date = day.date {
                withAnimation(.easeInOut(duration: 0.15)) {
                    selectedDate = date
                }
            }
        } label: {
            VStack(spacing: 3) {
                if let dayNum = day.dayNumber {
                    Text("\(dayNum)")
                        .font(.caption.weight(isSelected(day) ? .bold : .regular))
                        .foregroundStyle(dayTextColor(day))
                } else {
                    Text(" ")
                        .font(.caption)
                }

                // Content dot
                Circle()
                    .fill(day.hasContent ? Color.dayreadGold : .clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected(day) ? Color.dayreadGold.opacity(0.15) : .clear)
            )
        }
        .buttonStyle(.plain)
        .disabled(day.date == nil)
    }

    // MARK: - Selected Date Content

    private var selectedDateContent: some View {
        let dateStr = formatDateKey(selectedDate)
        let items = PremiumContent.itemsFor(date: dateStr)

        return VStack(alignment: .leading, spacing: 10) {
            Text(formatDateDisplay(selectedDate))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.dayreadGold)
                .padding(.bottom, 2)

            if items.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                        Text("이 날짜에 배정된 콘텐츠가 없습니다")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(items) { item in
                    premiumItemRow(item)
                }
            }
        }
    }

    // MARK: - Item Row

    private func premiumItemRow(_ item: PremiumContentItem) -> some View {
        let isFreeItem = membershipTier != .premium && PremiumContent.canFreeUserOpen(item)

        return Button {
            if let sessionId = item.sessionId, sessionMap[sessionId] != nil {
                if membershipTier == .premium || isFreeItem {
                    onSessionTap(sessionId)
                } else {
                    onShowPaywall()
                }
            } else {
                if membershipTier != .premium && !isFreeItem {
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

                if isFreeItem {
                    Text("무료")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.green.opacity(0.12)))
                } else if membershipTier != .premium {
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

    // MARK: - Calendar Helpers

    private struct CalendarDay {
        let dayNumber: Int?
        let date: Date?
        let hasContent: Bool
        let isCurrentMonth: Bool
    }

    private func calendarDays() -> [CalendarDay] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) // 1=Sun
        let leadingBlanks = firstWeekday - 1

        var days: [CalendarDay] = []

        // Leading blanks
        for _ in 0..<leadingBlanks {
            days.append(CalendarDay(dayNumber: nil, date: nil, hasContent: false, isCurrentMonth: false))
        }

        // Actual days
        for day in range {
            var dayComps = comps
            dayComps.day = day
            let date = calendar.date(from: dayComps)
            let dateKey = date.map { formatDateKey($0) } ?? ""
            let hasContent = !PremiumContent.itemsFor(date: dateKey).isEmpty
            days.append(CalendarDay(dayNumber: day, date: date, hasContent: hasContent, isCurrentMonth: true))
        }

        // Trailing blanks to complete last row
        let remainder = days.count % 7
        if remainder > 0 {
            for _ in 0..<(7 - remainder) {
                days.append(CalendarDay(dayNumber: nil, date: nil, hasContent: false, isCurrentMonth: false))
            }
        }

        return days
    }

    private func isSelected(_ day: CalendarDay) -> Bool {
        guard let date = day.date else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }

    private func isToday(_ day: CalendarDay) -> Bool {
        guard let date = day.date else { return false }
        return calendar.isDateInToday(date)
    }

    private func dayTextColor(_ day: CalendarDay) -> Color {
        if isSelected(day) { return Color.dayreadGold }
        if isToday(day) { return .primary }
        if !day.isCurrentMonth { return Color.secondary.opacity(0.4) }
        if day.hasContent { return .primary }
        return .secondary
    }

    private var monthYearString: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 M월"
        return fmt.string(from: displayedMonth)
    }

    private func formatDateKey(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    private func formatDateDisplay(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "M월 d일 (E)"
        return fmt.string(from: date)
    }
}

// MARK: - Array Extension

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
