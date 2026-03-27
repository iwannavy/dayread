import SwiftUI

struct ImmersiveView: View {
    let sentences: [AnalyzedSentence]
    let initialIndex: Int
    let onAdvanceMode: () -> Void
    let onSentenceChange: (Int) -> Void
    let onStudied: (Int) -> Void

    @State private var sentenceIndex: Int
    @State private var swipeOffset: CGFloat = 0
    @State private var swipeTriggered = false
    private let hapticLight = UIImpactFeedbackGenerator(style: .light)
    private let hapticMedium = UIImpactFeedbackGenerator(style: .medium)

    init(sentences: [AnalyzedSentence], initialIndex: Int,
         onAdvanceMode: @escaping () -> Void,
         onSentenceChange: @escaping (Int) -> Void,
         onStudied: @escaping (Int) -> Void) {
        self.sentences = sentences
        self.initialIndex = initialIndex
        self.onAdvanceMode = onAdvanceMode
        self.onSentenceChange = onSentenceChange
        self.onStudied = onStudied
        _sentenceIndex = State(initialValue: initialIndex)
    }

    private var sentence: AnalyzedSentence? { sentences[safe: sentenceIndex] }
    private var isLastSentence: Bool { sentenceIndex == sentences.count - 1 }

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Previous sentences (faded context)
                previousSentences
                    .id("immersiveTop")

                if let sentence {
                    // Counter
                    Text("\(sentenceIndex + 1) / \(sentences.count)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                        .padding(.bottom, StudyLayout.spacingSM)

                    // English sentence
                    Text(sentence.original)
                        .studySentenceStyle()
                        .foregroundStyle(.primary)
                        .padding(.bottom, StudyLayout.spacingBase)

                    // Korean translation
                    Text(sentence.translation)
                        .studyTranslationStyle()
                        .padding(.bottom, StudyLayout.spacingLG)

                    // Phrase translation
                    if let alignment = sentence.koreanAlignment, !alignment.isEmpty {
                        phraseSection(alignment)
                            .padding(.bottom, StudyLayout.spacingLG)
                    }

                    // Key vocabulary
                    if !sentence.vocabulary.isEmpty {
                        vocabularySection(sentence.vocabulary)
                            .padding(.bottom, StudyLayout.spacingBase)
                    }

                    // Expressions
                    if !sentence.expressions.isEmpty {
                        expressionsSection(sentence.expressions)
                            .padding(.bottom, StudyLayout.spacingBase)
                    }

                    // Compact grammar summary
                    GrammarVizView(
                        elements: sentence.grammarElements,
                        translation: sentence.translation,
                        original: sentence.original,
                        hideOriginal: true,
                        allActive: true,
                        compact: true
                    )
                    .padding(StudyLayout.cardPadding)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusMD))
                    .padding(.bottom, StudyLayout.spacingXL)

                    // Swipe-up navigation zone
                    swipeUpZone
                }
            }
            .padding(.horizontal, StudyLayout.pageHorizontal)
            .padding(.top, StudyLayout.spacingBase)
            .padding(.bottom, StudyLayout.spacingXXL)
        }
        .onChange(of: sentenceIndex) { _, _ in
            swipeOffset = 0
            swipeTriggered = false
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo("immersiveTop", anchor: .top)
            }
        }
        }
    }

    // MARK: - Previous Sentences

    @ViewBuilder
    private var previousSentences: some View {
        let prevSlice = Array(sentences.prefix(sentenceIndex).suffix(3))
        if !prevSlice.isEmpty {
            let groups = groupByParagraph(prevSlice)
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(groups.enumerated()), id: \.offset) { gi, group in
                    Text(group.texts.joined(separator: " "))
                        .studyContextStyle()
                        .opacity(0.35 + Double(gi) / max(Double(groups.count), 1) * 0.3)
                }
            }
            .padding(.bottom, StudyLayout.spacingMD)
        }
    }

    // MARK: - Phrase Translation

    private func phraseSection(_ alignment: [KoreanAlignment]) -> some View {
        VStack(alignment: .leading, spacing: StudyLayout.spacingSM) {
            Text("구 번역")
                .studySectionHeaderStyle()

            VStack(spacing: 8) {
                ForEach(Array(alignment.enumerated()), id: \.offset) { _, pair in
                    HStack {
                        Text(pair.en)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text("=")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                        Text(pair.ko)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    // MARK: - Vocabulary

    private func vocabularySection(_ vocabulary: [AnalyzedWord]) -> some View {
        VStack(alignment: .leading, spacing: StudyLayout.spacingSM) {
            Text("핵심 단어")
                .studySectionHeaderStyle()

            FlowLayout(spacing: 8) {
                ForEach(Array(vocabulary.prefix(6).enumerated()), id: \.offset) { _, v in
                    HStack(spacing: 4) {
                        Text(v.word).fontWeight(.medium)
                        Text("·").foregroundStyle(.tertiary)
                        Text(v.meaning).foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Expressions

    private func expressionsSection(_ expressions: [Expression]) -> some View {
        VStack(alignment: .leading, spacing: StudyLayout.spacingSM) {
            Text("표현")
                .studySectionHeaderStyle()

            FlowLayout(spacing: 8) {
                ForEach(Array(expressions.prefix(4).enumerated()), id: \.offset) { _, ex in
                    HStack(spacing: 4) {
                        Text(ex.phrase)
                        Text("·").foregroundStyle(.tertiary)
                        Text(ex.meaning).foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.dayreadGold.opacity(0.08))
                    .clipShape(Capsule())
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Swipe-Up Navigation Zone

    private var swipeUpZone: some View {
        VStack(spacing: StudyLayout.spacingSM) {
            Text("\(sentenceIndex + 1) / \(sentences.count)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .monospacedDigit()

            if isLastSentence {
                Text("Immersive 학습 완료!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
                Text("다음은 Focus에서 심층 분석합니다")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Swipe indicator with live feedback
            VStack(spacing: 4) {
                Image(systemName: "chevron.compact.up")
                    .font(.title2)
                    .foregroundColor(swipeTriggered ? Color.dayreadGold : Color.gray.opacity(0.4))
                    .scaleEffect(1 + min(0.3, abs(swipeOffset) / 200))
                    .offset(y: swipeOffset * 0.3)

                Text(isLastSentence ? "스와이프하여 Focus 단계로" : "스와이프하여 다음 문장")
                    .font(.caption2)
                    .foregroundColor(swipeTriggered ? Color.dayreadGold : Color.gray.opacity(0.3))
            }
            .padding(.top, StudyLayout.spacingSM)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    let dy = value.translation.height
                    guard dy < 0 else {
                        swipeOffset = 0
                        swipeTriggered = false
                        return
                    }
                    // Dampened rubber-band offset
                    swipeOffset = dy * 0.4
                    let newTriggered = dy < -50
                    if newTriggered && !swipeTriggered {
                        hapticLight.impactOccurred()
                    }
                    swipeTriggered = newTriggered
                }
                .onEnded { value in
                    let dy = value.translation.height
                    let vy = value.velocity.height
                    let predicted = value.predictedEndTranslation.height

                    if swipeTriggered || (dy < -30 && vy < -400) || predicted < -80 {
                        hapticMedium.impactOccurred()
                        if isLastSentence {
                            onStudied(sentence!.id)
                            onAdvanceMode()
                        } else {
                            goToNextSentence()
                        }
                    }

                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        swipeOffset = 0
                        swipeTriggered = false
                    }
                }
        )
        .padding(.bottom, StudyLayout.spacingXXL)
    }

    // MARK: - Actions

    private func goToNextSentence() {
        if let s = sentence { onStudied(s.id) }
        let nextIdx = sentenceIndex + 1
        sentenceIndex = nextIdx
        onSentenceChange(nextIdx)
    }

    // MARK: - Helpers

    private func groupByParagraph(_ slice: [AnalyzedSentence]) -> [(pIdx: Int, texts: [String])] {
        var groups: [(pIdx: Int, texts: [String])] = []
        for s in slice {
            let pIdx = s.paragraphIndex
            if let last = groups.last, last.pIdx == pIdx {
                groups[groups.count - 1].texts.append(s.original)
            } else {
                groups.append((pIdx: pIdx, texts: [s.original]))
            }
        }
        return groups
    }
}

// MARK: - Safe Array Access

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
