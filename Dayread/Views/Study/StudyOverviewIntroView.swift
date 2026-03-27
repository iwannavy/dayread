import SwiftUI

struct StudyOverviewIntroView: View {
    let sentences: [AnalyzedSentence]
    let sessionId: String
    var highlightIndex: Int? = nil
    let onComplete: () -> Void

    @State private var expandedIdx: Int? = nil
    @State private var hasReachedBottom = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome message
                VStack(spacing: 4) {
                    Text("먼저 글을 한번 읽어보세요")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text("궁금한 문장을 탭하면 문법 분석을 볼 수 있어요")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
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
        VStack(alignment: .leading, spacing: 0) {
            // Flowing paragraph text — sentences concatenated for natural word wrapping
            buildParagraphText(paragraph.items)
                .studySentenceStyle()
                .fixedSize(horizontal: false, vertical: true)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        handleParagraphTap(paragraph.items)
                    }
                }

            // Sentence selector (when expanded, multi-sentence paragraph)
            if paragraph.items.count > 1,
               paragraph.items.contains(where: { expandedIdx == $0.idx }) {
                HStack(spacing: 6) {
                    ForEach(paragraph.items, id: \.idx) { item in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                expandedIdx = item.idx
                            }
                        } label: {
                            Text("\(item.idx + 1)")
                                .font(.caption2)
                                .fontWeight(expandedIdx == item.idx ? .bold : .regular)
                                .frame(width: 24, height: 24)
                                .background(expandedIdx == item.idx ? Color.dayreadGold : Color.gray.opacity(0.2))
                                .foregroundStyle(expandedIdx == item.idx ? .white : .secondary)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, StudyLayout.spacingSM)
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
                    hideOriginal: true
                )
                .padding(StudyLayout.cardPadding)
                .background(.quaternary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))
                .padding(.vertical, StudyLayout.spacingSM)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
    }

    // MARK: - Paragraph Text Building

    private func buildParagraphText(_ items: [(sentence: AnalyzedSentence, idx: Int)]) -> Text {
        var result = Text("")
        for (i, item) in items.enumerated() {
            if i > 0 { result = result + Text(" ") }
            if expandedIdx == item.idx {
                result = result + Text(item.sentence.original)
                    .foregroundColor(.dayreadGold)
            } else if highlightIndex == item.idx {
                result = result + Text(item.sentence.original)
                    .foregroundColor(.yellow.opacity(0.8))
            } else {
                result = result + Text(item.sentence.original)
            }
        }
        return result
    }

    private func handleParagraphTap(_ items: [(sentence: AnalyzedSentence, idx: Int)]) {
        if let current = expandedIdx,
           let currentPos = items.firstIndex(where: { $0.idx == current }) {
            let nextPos = currentPos + 1
            if nextPos < items.count {
                expandedIdx = items[nextPos].idx
            } else {
                expandedIdx = nil
            }
        } else if let first = items.first {
            expandedIdx = first.idx
        }
    }
}
