import SwiftUI

struct FlashcardReviewView: View {
    @Environment(SRSService.self) private var srsService
    @Environment(\.dismiss) private var dismiss

    @State private var dueItems: [SRSItem] = []
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var sessionComplete = false
    @State private var reviewedCount = 0

    var body: some View {
        VStack(spacing: 0) {
            if sessionComplete {
                completionView
            } else if dueItems.isEmpty {
                emptyView
            } else {
                flashcardView
            }
        }
        .navigationTitle("복습")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadDueItems()
            if !srsService.getDueItems().isEmpty {
                AnalyticsService.track("review_started", properties: ["due_count": srsService.getDueItems().count])
            }
        }
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("복습할 항목이 없습니다")
                .font(.title3.bold())

            Text("학습 중 단어를 저장하면 여기에 나타납니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.dayreadGold)

            Text("잘했어요!")
                .font(.title2.bold())

            Text("\(reviewedCount)개 항목을 복습했습니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("돌아가기") { dismiss() }
                .font(.body.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.dayreadGold, in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 40)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Flashcard

    private var flashcardView: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { proxy in
                let width = proxy.size.width * (CGFloat(currentIndex) / CGFloat(max(dueItems.count, 1)))
                Rectangle()
                    .fill(Color.dayreadGold)
                    .frame(width: width, height: 3)
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
            .frame(height: 3)

            // Stats header
            statsHeader

            Spacer()

            // Card
            cardContent

            Spacer()

            // Actions
            if showAnswer {
                qualityButtons
            } else {
                showAnswerButton
            }
        }
    }

    private var statsHeader: some View {
        let stats = srsService.getStats()
        return HStack(spacing: 16) {
            statBadge("전체", value: stats.due + stats.learning + stats.mature + stats.new, color: .secondary)
            statBadge("복습 대기", value: stats.due, color: Color.dayreadGold)
            statBadge("학습 중", value: stats.learning, color: .blue)
            statBadge("숙달", value: stats.mature, color: .green)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private func statBadge(_ label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.subheadline.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var cardContent: some View {
        if let item = dueItems[safe: currentIndex] {
            VStack(spacing: 16) {
                // Type badge
                Text(item.type.displayName)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(item.type.badgeColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(item.type.badgeColor)

                // Front (question)
                Text(item.front)
                    .font(.title2.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                if showAnswer {
                    Divider()
                        .padding(.horizontal, 40)

                    // Back (answer)
                    Text(item.back)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Position counter
                Text("\(currentIndex + 1) / \(dueItems.count)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 20)
            .animation(.easeInOut(duration: 0.2), value: showAnswer)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(item.type.displayName): \(item.front)")
            .accessibilityValue(showAnswer ? "정답: \(item.back)" : "탭하여 정답 보기")
            .accessibilityHint("\(currentIndex + 1)/\(dueItems.count)")
        }
    }

    private var showAnswerButton: some View {
        Button {
            withAnimation { showAnswer = true }
        } label: {
            Text("정답 보기")
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(Color.dayreadGold, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private var qualityButtons: some View {
        HStack(spacing: 10) {
            qualityButton(label: "다시", quality: 1, color: Color(red: 0.69, green: 0.31, blue: 0.31))
            qualityButton(label: "어려움", quality: 3, color: Color(red: 0.69, green: 0.47, blue: 0.22))
            qualityButton(label: "좋음", quality: 4, color: Color(red: 0.6, green: 0.52, blue: 0.38))
            qualityButton(label: "쉬움", quality: 5, color: Color(red: 0.18, green: 0.48, blue: 0.18))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func qualityButton(label: String, quality: Int, color: Color) -> some View {
        Button {
            handleReview(quality: quality)
        } label: {
            Text(label)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle(.white)
                .background(color, in: RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Actions

    private func loadDueItems() {
        dueItems = srsService.getDueItems()
        currentIndex = 0
        showAnswer = false
        sessionComplete = false
        reviewedCount = 0
    }

    private func handleReview(quality: Int) {
        guard let item = dueItems[safe: currentIndex] else { return }

        srsService.reviewItem(id: item.id, quality: quality)
        reviewedCount += 1

        if currentIndex + 1 < dueItems.count {
            currentIndex += 1
            showAnswer = false
        } else {
            sessionComplete = true
            AnalyticsService.track("review_completed", properties: ["reviewed_count": reviewedCount])
        }
    }
}

// MARK: - SRSItemType Display Helpers

extension SRSItemType {
    var displayName: String {
        switch self {
        case .vocabulary: return "단어"
        case .pattern: return "패턴"
        case .expression: return "표현"
        }
    }

    var badgeColor: Color {
        switch self {
        case .vocabulary: return .blue
        case .pattern: return Color.dayreadGold
        case .expression: return .purple
        }
    }
}