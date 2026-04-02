import SwiftUI

struct PatternDrillView: View {
    let pattern: String
    let examples: [String]
    let drillQuestions: [PatternDrillQuestion]
    var onComplete: (() -> Void)? = nil

    @State private var currentQ = 0
    @State private var userAnswer = ""
    @State private var selectedOption: String? = nil
    @State private var submitted = false
    @State private var correctCount = 0
    @State private var totalCount = 0
    @State private var showCorrectFeedback = false
    @State private var drillCompleted = false

    var body: some View {
        if drillQuestions.isEmpty {
            // No drill — show examples only
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(examples.prefix(2).enumerated()), id: \.offset) { _, ex in
                    Text(ex)
                        .font(.studyExample)
                        .foregroundStyle(.tertiary)
                        .padding(.leading, 12)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Color.dayreadGold.opacity(0.2))
                                .frame(width: 2)
                        }
                }
            }
        } else if drillCompleted {
            drillCompletedView
        } else {
            drillContent
        }
    }

    private var drillCompletedView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("완료됨")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(correctCount)/\(totalCount) 정답")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("다시 하기") { handleDrillReset() }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var drillContent: some View {
        let q = drillQuestions[currentQ]

        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(pattern)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("\(currentQ + 1)/\(drillQuestions.count) · \(correctCount)/\(totalCount) 정답")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }

            // Question
            VStack(alignment: .leading, spacing: 12) {
                Text(q.question)
                    .font(.subheadline)

                if let options = q.options, !options.isEmpty {
                    // MCQ
                    VStack(spacing: 8) {
                        ForEach(Array(options.enumerated()), id: \.offset) { _, opt in
                            Button {
                                if !submitted { selectedOption = opt }
                            } label: {
                                Text(opt)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(optionBackground(opt, answer: q.answer))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(optionBorder(opt, answer: q.answer), lineWidth: 1)
                                    )
                            }
                            .disabled(submitted)
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    // Text input
                    TextField("답변을 입력하세요...", text: $userAnswer)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)
                        .disabled(submitted)
                        .onSubmit {
                            if !submitted { handleSubmit() }
                        }
                }

                // Action button
                HStack {
                    Spacer()
                    if !submitted {
                        Button("확인") { handleSubmit() }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(canSubmit ? Color.dayreadGold : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .disabled(!canSubmit)
                    } else {
                        if showCorrectFeedback {
                            Text("정답이에요!")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.green)
                                .transition(.opacity)
                        }
                        Button(currentQ + 1 >= drillQuestions.count ? "완료" : "다음") {
                            handleNext()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(16)
            .background(.quaternary.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Logic

    private var canSubmit: Bool {
        let q = drillQuestions[currentQ]
        if q.options != nil {
            return selectedOption != nil
        }
        return !userAnswer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func handleSubmit() {
        let q = drillQuestions[currentQ]
        let answer = q.options != nil ? selectedOption : userAnswer
        let correct = answer?.lowercased().trimmingCharacters(in: .whitespaces)
            == q.answer.lowercased().trimmingCharacters(in: .whitespaces)
        submitted = true
        correctCount += correct ? 1 : 0
        totalCount += 1

        if correct {
            withAnimation { showCorrectFeedback = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showCorrectFeedback = false }
            }
        }
    }

    private func handleNext() {
        showCorrectFeedback = false
        if currentQ + 1 >= drillQuestions.count {
            drillCompleted = true
            onComplete?()
        } else {
            currentQ += 1
            submitted = false
            userAnswer = ""
            selectedOption = nil
        }
    }

    private func handleDrillReset() {
        currentQ = 0
        userAnswer = ""
        selectedOption = nil
        submitted = false
        correctCount = 0
        totalCount = 0
        showCorrectFeedback = false
        drillCompleted = false
    }

    // MARK: - Option Styling

    private func optionBackground(_ opt: String, answer: String) -> Color {
        guard submitted else {
            return opt == selectedOption ? Color.dayreadGold.opacity(0.1) : Color.gray.opacity(0.08)
        }
        if opt == answer { return Color.green.opacity(0.08) }
        if opt == selectedOption { return Color.red.opacity(0.08) }
        return Color.gray.opacity(0.08)
    }

    private func optionBorder(_ opt: String, answer: String) -> Color {
        guard submitted else {
            return opt == selectedOption ? Color.dayreadGold.opacity(0.3) : Color.gray.opacity(0.15)
        }
        if opt == answer { return Color.green.opacity(0.3) }
        if opt == selectedOption { return Color.red.opacity(0.3) }
        return Color.gray.opacity(0.15)
    }
}
