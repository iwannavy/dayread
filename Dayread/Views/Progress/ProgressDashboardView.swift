import SwiftUI
import Charts

enum ProgressTab: String, CaseIterable {
    case dashboard = "대시보드"
    case curriculum = "커리큘럼"
}

struct ProgressDashboardView: View {
    @Environment(StudyProgressService.self) private var progressService
    @Environment(LibraryService.self) private var libraryService

    @State private var showReview = false
    @State private var selectedTab: ProgressTab = .dashboard

    private var progress: LearningProgress { progressService.progress }

    var body: some View {
        VStack(spacing: 0) {
            // Segment picker
            Picker("", selection: $selectedTab) {
                ForEach(ProgressTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            switch selectedTab {
            case .dashboard:
                ScrollView {
                    VStack(spacing: 24) {
                        streakSection
                        if progress.totalSentencesStudied == 0 && progress.streak == 0 {
                            VStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.title2)
                                    .foregroundStyle(Color.dayreadGold)
                                Text("학습을 시작하면 진도가 여기에 표시됩니다")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 24)
                        } else {
                            statsGrid
                            weeklyChartSection
                        }
                        reviewSection
                    }
                    .padding()
                }
            case .curriculum:
                CurriculumMapView()
            }
        }
        .navigationTitle("진도")
        .navigationDestination(isPresented: $showReview) {
            FlashcardReviewView()
        }
    }

    // MARK: - Streak

    private var streakSection: some View {
        VStack(spacing: 12) {
            // Flame icon with tier-based color
            streakFlame
                .frame(width: 64, height: 64)

            Text("\(progress.streak)일 연속")
                .font(.title2.bold())

            Text(streakMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Last 7 days activity dots
            HStack(spacing: 8) {
                ForEach(last7DaysActivity, id: \.date) { day in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(day.active ? Color.dayreadGold : Color(.systemGray5))
                            .frame(width: 10, height: 10)

                        Text(day.label)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var streakFlame: some View {
        let tier = streakTier
        let colors: [Color] = switch tier {
        case 0: [.gray]
        case 1: [.orange, .yellow]
        case 2: [.orange, Color(red: 0.85, green: 0.35, blue: 0.05)]
        case 3: [.red, .orange]
        default: [.red, .orange, .yellow]
        }

        Image(systemName: tier == 0 ? "flame" : "flame.fill")
            .font(.system(size: 40))
            .foregroundStyle(
                LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top)
            )
    }

    private var streakTier: Int {
        let s = progress.streak
        if s == 0 { return 0 }
        if s <= 3 { return 1 }
        if s <= 7 { return 2 }
        if s <= 14 { return 3 }
        if s <= 30 { return 4 }
        return 5
    }

    private var streakMessage: String {
        switch streakTier {
        case 0: return "오늘 첫 학습을 시작해보세요"
        case 1: return "좋은 시작이에요! 계속 이어가세요"
        case 2: return "꾸준히 학습하고 있어요!"
        case 3: return "대단해요! 습관이 만들어지고 있어요"
        default: return "놀라운 기록이에요!"
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(icon: "book.closed.fill", label: "세션", value: "\(progress.totalSessions)")
            statCard(icon: "text.line.first.and.arrowtriangle.forward", label: "문장", value: "\(progress.totalSentencesStudied)")
            statCard(icon: "checkmark.circle.fill", label: "연습", value: "\(progress.totalExercisesCompleted)")
            statCard(icon: "flame.fill", label: "스트릭", value: "\(progress.streak)일")
        }
    }

    private func statCard(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.dayreadGold)

            Text(value)
                .font(.title3.bold())

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Weekly Chart

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주 학습")
                .font(.headline)

            let weekData = thisWeekData

            if weekData.isEmpty {
                Text("이번 주 학습 기록이 없습니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                Chart(weekData, id: \.date) { entry in
                    BarMark(
                        x: .value("요일", entry.label),
                        y: .value("문장", entry.sentences)
                    )
                    .foregroundStyle(Color.dayreadGold.gradient)
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 160)
            }

            // Weekly totals
            let weekTotals = weekData.reduce(into: (sentences: 0, exercises: 0)) { result, day in
                result.sentences += day.sentences
                result.exercises += day.exercises
            }

            HStack(spacing: 16) {
                Label("\(weekTotals.sentences) 문장", systemImage: "text.line.first.and.arrowtriangle.forward")
                Label("\(weekTotals.exercises) 연습", systemImage: "checkmark.circle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Review Section

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("복습")
                    .font(.headline)
                Spacer()
                Button("전체 보기") { showReview = true }
                    .font(.subheadline)
                    .foregroundStyle(Color.dayreadGold)
            }

            Text("학습 중 저장한 단어와 표현을 복습하세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showReview = true
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("복습 시작")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle(.white)
                .background(Color.dayreadGold, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Data Helpers

    private struct DayActivity: Identifiable {
        let date: String
        let label: String
        let active: Bool
        var id: String { date }
    }

    private var last7DaysActivity: [DayActivity] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        let dayLabels = ["일", "월", "화", "수", "목", "금", "토"]
        let activeDates = Set(progress.dailyLog.map(\.date))

        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            let dateStr = formatter.string(from: date)
            let weekday = calendar.component(.weekday, from: date) - 1
            return DayActivity(
                date: dateStr,
                label: dayLabels[weekday],
                active: activeDates.contains(dateStr)
            )
        }
    }

    private struct WeekDayData {
        let date: String
        let label: String
        let sentences: Int
        let exercises: Int
    }

    private var thisWeekData: [WeekDayData] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        let dayLabels = ["일", "월", "화", "수", "목", "금", "토"]
        let logMap = Dictionary(uniqueKeysWithValues: progress.dailyLog.map { ($0.date, $0) })

        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            let dateStr = formatter.string(from: date)
            let weekday = calendar.component(.weekday, from: date) - 1
            let log = logMap[dateStr]
            return WeekDayData(
                date: dateStr,
                label: dayLabels[weekday],
                sentences: log?.sentencesStudied ?? 0,
                exercises: log?.exercisesDone ?? 0
            )
        }
    }
}
