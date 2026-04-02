import SwiftUI

struct SentenceWriteCard: View {
    let sentence: String
    let translation: String
    let index: Int
    let total: Int
    let onComplete: (Int) -> Void

    @State private var available: [String] = []
    @State private var selected: [String] = []
    @State private var submitted = false

    private let words: [String]
    private let shuffled: [String]

    init(sentence: String, translation: String, index: Int, total: Int, onComplete: @escaping (Int) -> Void) {
        self.sentence = sentence
        self.translation = translation
        self.index = index
        self.total = total
        self.onComplete = onComplete

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

    var body: some View {
        VStack(spacing: 16) {
            // Type badge
            Text("문장")
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15), in: Capsule())
                .foregroundStyle(.green)

            // Korean translation prompt
            VStack(alignment: .leading, spacing: 4) {
                Text(translation)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text("위 번역을 보고 영어 문장을 완성하세요")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if !submitted {
                // Answer area
                FlowLayout(spacing: 8) {
                    if selected.isEmpty {
                        Text("단어를 탭해서 문장을 만드세요")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
                .frame(minHeight: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.quaternary, lineWidth: 1)
                )

                // Word bank
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
                    Button("확인") { handleSubmit() }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.dayreadGold, in: RoundedRectangle(cornerRadius: 10))
                }
            } else {
                // Result
                resultView
            }

            // Position counter
            Text("\(index + 1) / \(total)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
        .onAppear {
            available = shuffled
            selected = []
            submitted = false
        }
    }

    // MARK: - Result

    private var resultView: some View {
        VStack(alignment: .leading, spacing: 12) {
            buildResultText()
                .font(.body.weight(.medium))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            if selected.joined(separator: " ").lowercased() != words.joined(separator: " ").lowercased() {
                HStack(spacing: 4) {
                    Text("내 순서:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(selected.joined(separator: " "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

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
            if selected[safe: i]?.lowercased() == w.lowercased() { correct += 1 }
        }
        let ratio = Double(correct) / Double(max(words.count, 1))
        let quality: Int
        if ratio >= 1.0 { quality = 5 }
        else if ratio >= 0.8 { quality = 4 }
        else if ratio >= 0.6 { quality = 3 }
        else { quality = 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete(quality)
        }
    }
}
