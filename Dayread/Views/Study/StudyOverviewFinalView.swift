import SwiftUI

struct StudyOverviewFinalView: View {
    let sentences: [AnalyzedSentence]
    let overview: TextOverview
    let studiedCount: Int
    let getState: (Int) -> SentenceLearningState
    var highlightIndex: Int? = nil

    @State private var selectedIndex: Int? = nil
    @State private var showSummary = false
    @State private var animateCheckmark = false

    private var progress: Int {
        guard !sentences.isEmpty else { return 0 }
        return Int(round(Double(studiedCount) / Double(sentences.count) * 100))
    }

    var body: some View {
        VStack(spacing: 16) {
            // Welcome message / Celebration
            VStack(spacing: 8) {
                if progress == 100 {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.dayreadGold)
                        .scaleEffect(animateCheckmark ? 1.0 : 0.5)
                        .opacity(animateCheckmark ? 1.0 : 0.0)
                        .padding(.bottom, 4)

                    Text("오늘의 학습을 모두 마쳤습니다!")
                        .font(.headline)
                        .foregroundStyle(.primary)
                } else {
                    Text("마무리로 한번 더 읽어보세요")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Text("미흡한 부분이 있으면 문장을 탭해서 다시 확인해요")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 16)
            .onAppear {
                if progress == 100 {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        animateCheckmark = true
                    }
                    HapticsService.shared.success()
                }
            }

            // Full text — flowing paragraphs
            VStack(alignment: .leading, spacing: 20) {
                ForEach(paragraphGroups, id: \.pIdx) { paragraph in
                    buildFinalParagraphText(paragraph.items)
                        .studySentenceStyle()
                        .fixedSize(horizontal: false, vertical: true)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                handleFinalParagraphTap(paragraph.items)
                            }
                        }
                }
            }
            .padding(StudyLayout.cardPaddingLarge)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))

            // Sentence analysis sheet
            if let idx = selectedIndex, let sentence = sentences[safe: idx] {
                sentenceAnalysisCard(sentence, index: idx)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Session summary card
            summaryCard
                .onAppear { showSummary = true }
                .opacity(showSummary ? 1 : 0)
                .offset(y: showSummary ? 0 : 16)
                .animation(.easeOut(duration: 0.5), value: showSummary)
        }
        .padding(.horizontal, StudyLayout.pageHorizontal)
    }

    // MARK: - Paragraph Grouping

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
                    pIdx: pIdx, items: last.items + [(sentence, index)]
                )
            } else {
                groups.append(ParagraphGroup(pIdx: pIdx, items: [(sentence, index)]))
            }
        }
        return groups
    }

    // MARK: - Sentence Analysis Card

    private func sentenceAnalysisCard(_ sentence: AnalyzedSentence, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            GrammarVizView(
                elements: sentence.grammarElements,
                translation: sentence.translation,
                original: sentence.original,
                koreanAlignment: sentence.koreanAlignment,
                compact: true
            )
        }
        .padding(StudyLayout.cardPadding)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))
    }

    // MARK: - Paragraph Text Building

    private func buildFinalParagraphText(_ items: [(sentence: AnalyzedSentence, idx: Int)]) -> Text {
        var result = Text("")
        for (i, item) in items.enumerated() {
            if i > 0 { result = result + Text(" ") }
            if selectedIndex == item.idx {
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

    private func handleFinalParagraphTap(_ items: [(sentence: AnalyzedSentence, idx: Int)]) {
        if let current = selectedIndex,
           let currentPos = items.firstIndex(where: { $0.idx == current }) {
            let nextPos = currentPos + 1
            if nextPos < items.count {
                selectedIndex = items[nextPos].idx
            } else {
                selectedIndex = nil
            }
        } else if let first = items.first {
            selectedIndex = first.idx
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 16) {
            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                statItem(label: "단어", value: "\(overview.wordCount)")
                statItem(label: "문장", value: "\(overview.sentenceCount)")
                statItem(
                    label: "난이도",
                    value: String(repeating: "■", count: overview.difficulty)
                        + String(repeating: "□", count: 5 - overview.difficulty)
                )
                statItem(label: "읽기 시간", value: "\(overview.readingTimeMinutes)분")
            }

            // Progress bar
            VStack(spacing: 4) {
                HStack {
                    Text("진행률")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("\(studiedCount)/\(sentences.count) (\(progress)%)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.quaternary)
                        Capsule()
                            .fill(Color.dayreadGold)
                            .frame(width: geo.size.width * CGFloat(progress) / 100)
                    }
                }
                .frame(height: 6)
            }

            // Key Vocabulary
            let allVocab = sentences.flatMap(\.vocabulary).prefix(12)
            if !allVocab.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("핵심 어휘")
                        .studySectionHeaderStyle()
                    FlowLayout(spacing: 6) {
                        ForEach(Array(allVocab.enumerated()), id: \.offset) { _, v in
                            Text(v.word)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.quaternary.opacity(0.5))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // Key Expressions
            let allExpr = sentences.flatMap(\.expressions).prefix(8)
            if !allExpr.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("핵심 표현")
                        .studySectionHeaderStyle()
                    FlowLayout(spacing: 6) {
                        ForEach(Array(allExpr.enumerated()), id: \.offset) { _, ex in
                            Text(ex.phrase)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.dayreadGold.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(StudyLayout.cardPaddingLarge)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))
    }

    // MARK: - Stat Item

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.callout)
                .fontWeight(.medium)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
