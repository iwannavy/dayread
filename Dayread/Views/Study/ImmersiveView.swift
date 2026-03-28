import SwiftUI

struct ImmersiveView: View {
    let sentences: [AnalyzedSentence]
    let initialIndex: Int
    let onAdvanceMode: () -> Void
    let onSentenceChange: (Int) -> Void
    let onStudied: (Int) -> Void

    @State private var sentenceIndex: Int
    @State private var scrolledID: Int?
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
        _scrolledID = State(initialValue: initialIndex)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(sentences.enumerated()), id: \.offset) { idx, sentence in
                    sentenceCard(sentence, index: idx)
                        .containerRelativeFrame(.vertical)
                        .id(idx)
                }

                // Completion card after last sentence
                completionCard
                    .containerRelativeFrame(.vertical)
                    .id(sentences.count)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledID)
        .onChange(of: scrolledID) { _, newID in
            handleCardChange(newID)
        }
    }

    // MARK: - Sentence Card

    @ViewBuilder
    private func sentenceCard(_ sentence: AnalyzedSentence, index: Int) -> some View {
        ZStack(alignment: .bottom) {
            // Card content
            VStack(alignment: .leading, spacing: 0) {
                // Counter
                Text("\(index + 1) / \(sentences.count)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
                    .padding(.bottom, StudyLayout.spacingSM)
                    .accessibilityLabel("문장 \(index + 1)/\(sentences.count)")

                // English sentence
                Text(sentence.original)
                    .studySentenceStyle()
                    .foregroundStyle(.primary)
                    .padding(.bottom, StudyLayout.spacingBase)
                    .accessibilityLabel("영어 문장: \(sentence.original)")

                // Korean translation
                Text(sentence.translation)
                    .studyTranslationStyle()
                    .padding(.bottom, StudyLayout.spacingLG)
                    .accessibilityLabel("번역: \(sentence.translation)")

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

                Spacer(minLength: 0)
            }
            .padding(.horizontal, StudyLayout.immersiveHorizontal)
            .padding(.top, StudyLayout.spacingBase)
            .padding(.bottom, 60) // Room for fade + indicator

            // Bottom fade gradient
            LinearGradient(
                colors: [.clear, Color(.systemBackground)],
                startPoint: UnitPoint(x: 0.5, y: 0.7),
                endPoint: .bottom
            )
            .frame(height: 60)
            .allowsHitTesting(false)

            // Card indicator
            cardIndicator(index: index)
        }
        .clipped()
    }

    // MARK: - Completion Card

    private var completionCard: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)

            Text("Immersive 학습 완료!")
                .font(.title3.weight(.medium))

            Text("Focus 단계로 이동합니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            hapticMedium.impactOccurred()
            if let s = sentences.last { onStudied(s.id) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onAdvanceMode()
            }
        }
    }

    // MARK: - Card Indicator

    private func cardIndicator(index: Int) -> some View {
        HStack {
            Text("\(index + 1) / \(sentences.count)")
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.tertiary)

            Spacer()

            if index < sentences.count - 1 {
                HStack(spacing: 4) {
                    Text("다음")
                        .font(.caption2)
                    Image(systemName: "chevron.up")
                        .font(.caption2)
                }
                .foregroundStyle(.tertiary)
            } else {
                HStack(spacing: 4) {
                    Text("완료")
                        .font(.caption2)
                    Image(systemName: "chevron.up")
                        .font(.caption2)
                }
                .foregroundStyle(Color.dayreadGold)
            }
        }
        .padding(.horizontal, StudyLayout.immersiveHorizontal)
        .padding(.bottom, StudyLayout.spacingSM)
    }

    // MARK: - Card Change Handler

    private func handleCardChange(_ newID: Int?) {
        guard let newID, newID != sentenceIndex else { return }
        let oldIndex = sentenceIndex

        // Mark previous sentence as studied when advancing
        if newID > oldIndex, let s = sentences[safe: oldIndex] {
            onStudied(s.id)
        }

        hapticLight.impactOccurred()

        // Completion card reached
        if newID >= sentences.count {
            sentenceIndex = sentences.count - 1
            return
        }

        sentenceIndex = newID
        onSentenceChange(newID)
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
}

// MARK: - Safe Array Access

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
