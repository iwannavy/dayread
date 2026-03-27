import SwiftUI

/// 3-level summary viewer — port of web SummaryViewer.tsx
/// Levels: 1 (초급 Elementary), 2 (중급 High School), 3 (고급 Expert)
struct SummaryLevelView: View {
    let summaries: [SessionSummary]

    @Environment(TTSService.self) private var tts
    @State private var selectedLevel: Int = 1
    @State private var playingIndex: Int? = nil

    private var currentSummary: SessionSummary? {
        summaries.first { $0.level == selectedLevel }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("요약 읽기")
                .studySectionHeaderStyle()

            // Level tabs
            levelTabs

            // Sentences
            if let summary = currentSummary {
                sentenceList(summary.sentences)
            }
        }
        .padding(StudyLayout.cardPaddingLarge)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("요약 읽기")
    }

    // MARK: - Level Tabs

    private var levelTabs: some View {
        HStack(spacing: 0) {
            ForEach(summaries.sorted(by: { $0.level < $1.level }), id: \.level) { summary in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedLevel = summary.level
                        playingIndex = nil
                        tts.stop()
                    }
                } label: {
                    Text(summary.labelKo)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(selectedLevel == summary.level ? .white : .secondary)
                        .background(
                            selectedLevel == summary.level
                                ? Color.dayreadGold
                                : Color.clear
                        )
                }
                .accessibilityLabel("\(summary.labelKo) 요약")
                .accessibilityAddTraits(selectedLevel == summary.level ? .isSelected : [])
            }
        }
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Sentence List

    private func sentenceList(_ sentences: [SummarySentence]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Play all button
            Button {
                playAll(sentences)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: playingIndex != nil ? "stop.fill" : "play.fill")
                        .font(.caption2)
                    Text(playingIndex != nil ? "정지" : "전체 재생")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(Color.dayreadGold)
            }

            ForEach(Array(sentences.enumerated()), id: \.element.id) { index, sentence in
                sentenceRow(sentence, index: index)
            }
        }
    }

    private func sentenceRow(_ sentence: SummarySentence, index: Int) -> some View {
        let isPlaying = playingIndex == index

        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                Text("\(index + 1)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 4) {
                    highlightedText(sentence.text, keyWords: sentence.keyWords)
                        .font(.subheadline)
                        .lineSpacing(4)

                    Text(sentence.translation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(isPlaying ? Color.dayreadGold.opacity(0.08) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
            .onTapGesture {
                playSentence(sentence.text, index: index)
            }
        }
    }

    // MARK: - Keyword Highlighting

    private func highlightedText(_ text: String, keyWords: [String]) -> Text {
        guard !keyWords.isEmpty else { return Text(text) }

        let lowercaseKeywords = Set(keyWords.map { $0.lowercased() })
        let words = text.components(separatedBy: " ")
        var result = Text("")

        for (i, word) in words.enumerated() {
            let stripped = word.trimmingCharacters(in: .punctuationCharacters)
            let isKeyWord = lowercaseKeywords.contains(stripped.lowercased())

            if i > 0 { result = result + Text(" ") }

            if isKeyWord {
                result = result + Text(word)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.dayreadGold)
            } else {
                result = result + Text(word)
            }
        }

        return result
    }

    // MARK: - TTS (callback-based)

    private func playSentence(_ text: String, index: Int) {
        if playingIndex == index {
            tts.stop()
            playingIndex = nil
        } else {
            playingIndex = index
            tts.speak(text) { [self] in
                if playingIndex == index {
                    playingIndex = nil
                }
            }
        }
    }

    private func playAll(_ sentences: [SummarySentence]) {
        if playingIndex != nil {
            tts.stop()
            playingIndex = nil
            return
        }

        playSequence(sentences, from: 0)
    }

    private func playSequence(_ sentences: [SummarySentence], from index: Int) {
        guard index < sentences.count else {
            playingIndex = nil
            return
        }

        playingIndex = index
        tts.speak(sentences[index].text) { [self] in
            playSequence(sentences, from: index + 1)
        }
    }
}
