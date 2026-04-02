import SwiftUI

struct StudyOverviewIntroView: View {
    let sentences: [AnalyzedSentence]
    let sessionId: String
    var highlightIndex: Int? = nil
    let onComplete: () -> Void

    @State private var expandedIdx: Int? = nil
    @State private var hasReachedBottom = false
    @State private var activeGrammarWord: String? = nil
    @State private var activeGrammarSentenceIdx: Int? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome message
                VStack(spacing: 4) {
                    Text("먼저 글을 한번 읽어보세요")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text("궁금한 문장을 탭해보세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, StudyLayout.spacingBase)

                // Full text with inline expandable GrammarViz
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(paragraphGroups, id: \.pIdx) { paragraph in
                        paragraphView(paragraph)
                    }
                }
                .padding(StudyLayout.cardPaddingLarge)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))

                // Bottom sentinel + CTA
                VStack(spacing: 12) {
                    Text("이제 한 문장씩 공부해볼까요?")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button(action: {
                        if hasReachedBottom { onComplete() }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "chevron.down")
                                .font(.title3)
                            if hasReachedBottom {
                                Text("시작하기")
                                    .font(.caption2)
                            }
                        }
                        .foregroundStyle(hasReachedBottom ? Color.dayreadGold : Color.gray)
                    }
                }
                .padding(.vertical, 32)
                .onAppear {
                    hasReachedBottom = true
                }
            }
            .padding(.horizontal, StudyLayout.pageHorizontal)
        }
    }

    // MARK: - Paragraph grouping

    private struct ParagraphGroup {
        let pIdx: Int
        let items: [(sentence: AnalyzedSentence, idx: Int)]
    }

    private var paragraphGroups: [ParagraphGroup] {
        var groups: [ParagraphGroup] = []
        for (index, sentence) in sentences.enumerated() {
            let pIdx = sentence.paragraphIndex
            if let last = groups.last, last.pIdx == pIdx {
                groups[groups.count - 1] = ParagraphGroup(
                    pIdx: pIdx,
                    items: last.items + [(sentence, index)]
                )
            } else {
                groups.append(ParagraphGroup(pIdx: pIdx, items: [(sentence, index)]))
            }
        }
        return groups
    }

    // MARK: - Paragraph View (flowing text)

    private func paragraphView(_ paragraph: ParagraphGroup) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            // Each sentence is individually tappable
            ForEach(paragraph.items, id: \.idx) { item in
                buildSentenceText(item)
                    .studySentenceStyle()
                    .fixedSize(horizontal: false, vertical: true)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if expandedIdx == item.idx {
                                expandedIdx = nil
                                activeGrammarWord = nil
                                activeGrammarSentenceIdx = nil
                            } else {
                                expandedIdx = item.idx
                                activeGrammarWord = nil
                                activeGrammarSentenceIdx = nil
                            }
                        }
                    }
            }

            // Inline GrammarViz for expanded sentence
            if let expandedItem = paragraph.items.first(where: { expandedIdx == $0.idx }) {
                GrammarVizView(
                    elements: expandedItem.sentence.grammarElements,
                    translation: expandedItem.sentence.translation,
                    original: expandedItem.sentence.original,
                    koreanAlignment: expandedItem.sentence.koreanAlignment,
                    notes: expandedItem.sentence.notes,
                    rhetoricalDevice: expandedItem.sentence.rhetoricalDevice,
                    hideOriginal: true,
                    onWordTap: { word in
                        activeGrammarWord = word
                        activeGrammarSentenceIdx = expandedItem.idx
                    }
                )
                .padding(StudyLayout.cardPadding)
                .background(.quaternary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))
                .padding(.vertical, StudyLayout.spacingSM)
                .transition(.opacity)
            }
        }
    }

    // MARK: - Sentence Text Building

    private func buildSentenceText(_ item: (sentence: AnalyzedSentence, idx: Int)) -> Text {
        // Grammar highlight: when a grammar element is tapped in GrammarViz
        if activeGrammarSentenceIdx == item.idx, let word = activeGrammarWord {
            return highlightGrammarWord(in: item.sentence, word: word)
        }
        // Expanded sentence: gold
        if expandedIdx == item.idx {
            return Text(item.sentence.original)
                .foregroundColor(.dayreadGold)
        }
        // Audio highlight
        if highlightIndex == item.idx {
            return Text(item.sentence.original)
                .foregroundColor(.yellow.opacity(0.8))
        }
        return Text(item.sentence.original)
    }

    private func highlightGrammarWord(in sentence: AnalyzedSentence, word: String) -> Text {
        let original = sentence.original
        // Independent matching — handles out-of-order grammar elements
        struct Match { let range: Range<String.Index>; let element: GrammarElement }
        var matches: [Match] = []
        var usedRanges: [Range<String.Index>] = []

        for el in sentence.grammarElements {
            let trimmed = el.text.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            var searchStart = original.startIndex
            while searchStart < original.endIndex {
                guard let range = original.range(of: trimmed, range: searchStart..<original.endIndex) else { break }
                let overlaps = usedRanges.contains { $0.lowerBound < range.upperBound && $0.upperBound > range.lowerBound }
                if !overlaps {
                    matches.append(Match(range: range, element: el))
                    usedRanges.append(range)
                    break
                }
                searchStart = range.upperBound
            }
        }
        matches.sort { $0.range.lowerBound < $1.range.lowerBound }

        var result = Text("")
        var pos = original.startIndex
        for match in matches {
            if match.range.lowerBound < pos { continue }
            if match.range.lowerBound > pos {
                result = result + Text(original[pos..<match.range.lowerBound])
            }
            let trimmed = match.element.text.trimmingCharacters(in: .whitespaces)
            if trimmed == word {
                let color = Color.grammarColor(for: match.element.role)
                result = result + Text(original[match.range])
                    .foregroundColor(color)
                    .underline(color: color.opacity(0.3))
            } else {
                result = result + Text(original[match.range])
            }
            pos = match.range.upperBound
        }
        if pos < original.endIndex {
            result = result + Text(original[pos...])
        }
        return result
    }
}
