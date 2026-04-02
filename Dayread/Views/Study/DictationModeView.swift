import SwiftUI

enum DictationExerciseMode: String {
    case translation, dictation
}

struct DictationModeView: View {
    let sentence: String
    let translation: String
    var translationDone: Bool = false
    var dictationDone: Bool = false
    var onComplete: ((Int) -> Void)? = nil
    var onModeComplete: ((DictationExerciseMode, Int) -> Void)? = nil

    @Environment(TTSService.self) private var tts

    @State private var exerciseMode: DictationExerciseMode = .translation
    @State private var played = false
    @State private var submitted = false
    @State private var available: [String] = []
    @State private var selected: [String] = []

    private let words: [String]
    private let shuffled: [String]

    init(sentence: String, translation: String,
         translationDone: Bool = false, dictationDone: Bool = false,
         onComplete: ((Int) -> Void)? = nil,
         onModeComplete: ((DictationExerciseMode, Int) -> Void)? = nil) {
        self.sentence = sentence
        self.translation = translation
        self.translationDone = translationDone
        self.dictationDone = dictationDone
        self.onComplete = onComplete
        self.onModeComplete = onModeComplete

        let w = sentence
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }
        self.words = w

        var arr = w
        for i in stride(from: arr.count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            arr.swapAt(i, j)
        }
        self.shuffled = arr
    }

    private var isCurrentModeDone: Bool {
        exerciseMode == .translation ? translationDone : dictationDone
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Mode toggle
            modeToggle

            if isCurrentModeDone && !submitted {
                // Already completed state
                completedView
            } else {
                // Prompt
                promptView

                if !submitted {
                    // Answer area
                    answerArea

                    // Available words
                    FlowLayout(spacing: 8) {
                        ForEach(Array(available.enumerated()), id: \.offset) { i, word in
                            Button {
                                handleSelect(word, at: i)
                            } label: {
                                Text(word)
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.quaternary.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Check button
                    if selected.count == words.count {
                        HStack {
                            Spacer()
                            Button("확인") { handleSubmit() }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.dayreadGold)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                } else {
                    // Result
                    resultView
                }
            }
        }
        .onAppear {
            available = shuffled
            selected = []
            submitted = false
            // Start on first incomplete mode
            if translationDone && !dictationDone {
                exerciseMode = .dictation
            } else {
                exerciseMode = .translation
            }
        }
    }

    private var completedView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("완료됨")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button("다시 하기") { handleReset() }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 12)
    }

    // MARK: - Mode Toggle

    private var modeToggle: some View {
        HStack {
            HStack(spacing: 2) {
                modeButton("번역", mode: .translation, done: translationDone)
                modeButton("받아쓰기", mode: .dictation, done: dictationDone)
            }
            .padding(2)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
    }

    private func modeButton(_ title: String, mode: DictationExerciseMode, done: Bool) -> some View {
        Button {
            exerciseMode = mode
            // Reset exercise state when switching modes
            available = shuffled
            selected = []
            submitted = false
            played = false
        } label: {
            HStack(spacing: 4) {
                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.green)
                }
                Text(title)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                if exerciseMode == mode {
                    RoundedRectangle(cornerRadius: 10).fill(.regularMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(exerciseMode == mode ? .primary : .secondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Prompt

    @ViewBuilder
    private var promptView: some View {
        if exerciseMode == .dictation {
            HStack(spacing: 12) {
                Button {
                    tts.speak(sentence) { played = true }
                } label: {
                    Image(systemName: tts.isSpeaking ? "stop.fill" : "play.fill")
                        .font(.body)
                        .frame(width: 40, height: 40)
                        .background(Color.dayreadGold.opacity(0.1))
                        .foregroundStyle(Color.dayreadGold)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(tts.isLoading)

                Text(played ? "다시 듣기" : "듣고 단어를 배열하세요")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text(translation)
                    .studyTranslationStyle()
                Text("위 번역을 보고 영어 문장을 완성하세요")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Answer Area

    private var answerArea: some View {
        FlowLayout(spacing: 8) {
            if selected.isEmpty {
                Text("단어를 탭해서 문장을 만드세요")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(Array(selected.enumerated()), id: \.offset) { i, word in
                    Button {
                        handleDeselect(at: i)
                    } label: {
                        Text(word)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.dayreadGold.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.dayreadGold.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(minHeight: 60)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    // MARK: - Result

    private func buildResultText() -> Text {
        var result = Text("")
        for (i, word) in words.enumerated() {
            if i > 0 { result = result + Text(" ") }
            let isCorrect = selected[safe: i]?.lowercased() == word.lowercased()
            result = result + Text(word)
                .foregroundColor(isCorrect ? .green : .red)
        }
        return result
    }

    private var resultView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Color-coded result
            buildResultText()
                .font(.studySentence)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)

            // User's order (if different)
            if selected.joined(separator: " ").lowercased() != words.joined(separator: " ").lowercased() {
                HStack(spacing: 4) {
                    Text("내 순서:")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(selected.joined(separator: " "))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Button("다시 시도") { handleReset() }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Actions

    private func handleSelect(_ word: String, at index: Int) {
        selected.append(word)
        available.remove(at: index)
    }

    private func handleDeselect(at index: Int) {
        let word = selected[index]
        selected.remove(at: index)
        available.append(word)
    }

    private func handleSubmit() {
        submitted = true
        var correct = 0
        for (i, w) in words.enumerated() {
            if selected[safe: i]?.lowercased() == w.lowercased() {
                correct += 1
            }
        }
        let score = words.isEmpty ? 0 : Int(round(Double(correct) / Double(words.count) * 100))
        onComplete?(score)
        if score >= 70 {
            onModeComplete?(exerciseMode, score)
        }
    }

    private func handleReset() {
        available = shuffled
        selected = []
        submitted = false
        played = false
    }
}

