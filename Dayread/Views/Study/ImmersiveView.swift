import SwiftUI

// MARK: - Card Phase

private enum CardPhase: Int, Comparable {
    case encounter = 0
    case comprehension = 1
    case deepDive = 2

    static func < (lhs: CardPhase, rhs: CardPhase) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct ImmersiveView: View {
    let sentences: [AnalyzedSentence]
    let initialIndex: Int
    let onAdvanceMode: () -> Void
    let onSentenceChange: (Int) -> Void
    let onStudied: (Int) -> Void
    let onFlagSentence: (Int, Bool) -> Void

    @Environment(SRSService.self) private var srsService

    @State private var sentenceIndex: Int
    @State private var scrolledID: Int?
    @State private var cardPhases: [Int: CardPhase] = [:]
    @State private var flaggedSentences: Set<Int> = []
    @State private var expandedVocabId: String?

    private let hapticSoft = UIImpactFeedbackGenerator(style: .soft)
    private let hapticLight = UIImpactFeedbackGenerator(style: .light)
    private let hapticMedium = UIImpactFeedbackGenerator(style: .medium)

    init(sentences: [AnalyzedSentence], initialIndex: Int,
         onAdvanceMode: @escaping () -> Void,
         onSentenceChange: @escaping (Int) -> Void,
         onStudied: @escaping (Int) -> Void,
         onFlagSentence: @escaping (Int, Bool) -> Void = { _, _ in }) {
        self.sentences = sentences
        self.initialIndex = initialIndex
        self.onAdvanceMode = onAdvanceMode
        self.onSentenceChange = onSentenceChange
        self.onStudied = onStudied
        self.onFlagSentence = onFlagSentence
        _sentenceIndex = State(initialValue: initialIndex)
        _scrolledID = State(initialValue: initialIndex)
    }

    private func phase(for index: Int) -> CardPhase {
        cardPhases[index] ?? .encounter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(sentences.enumerated()), id: \.offset) { idx, sentence in
                    sentenceCard(sentence, index: idx)
                        .containerRelativeFrame(.vertical)
                        .id(idx)
                }

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
        let currentPhase = phase(for: index)

        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Counter + difficulty dot
                    cardHeader(sentence, index: index)
                        .padding(.bottom, StudyLayout.spacingSM)

                    // Layer 0: English sentence (always visible)
                    englishSentence(sentence, index: index, phase: currentPhase)
                        .padding(.bottom, StudyLayout.spacingBase)

                    // Layer 1: Translation + grammar colors + phrase alignment
                    if currentPhase >= .comprehension {
                        comprehensionLayer(sentence, index: index)
                            .transition(.opacity.combined(with: .offset(y: 12)))
                    } else {
                        // Hint line
                        Text("번역 보려면 탭")
                            .font(.caption2)
                            .foregroundStyle(.quaternary)
                            .padding(.bottom, StudyLayout.spacingLG)
                            .transition(.opacity)
                    }

                    // Layer 2: Vocabulary + Expressions + Grammar
                    if currentPhase >= .deepDive {
                        deepDiveLayer(sentence, index: index)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, StudyLayout.immersiveHorizontal)
                .padding(.top, StudyLayout.spacingBase)
                .padding(.bottom, 60)
            }
            .scrollDisabled(currentPhase < .deepDive)

            // Bottom fade gradient
            LinearGradient(
                colors: [.clear, Color(.systemBackground)],
                startPoint: UnitPoint(x: 0.5, y: 0.7),
                endPoint: .bottom
            )
            .frame(height: 60)
            .allowsHitTesting(false)

            // Card indicator
            cardIndicator(index: index, phase: currentPhase)
        }
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap(index: index)
        }
    }

    // MARK: - Card Header

    private func cardHeader(_ sentence: AnalyzedSentence, index: Int) -> some View {
        HStack {
            Text("\(index + 1) / \(sentences.count)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .monospacedDigit()
                .accessibilityLabel("문장 \(index + 1)/\(sentences.count)")

            if flaggedSentences.contains(index) {
                Circle()
                    .fill(Color.dayreadGold)
                    .frame(width: 5, height: 5)
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            if sentence.difficulty >= 3 {
                Circle()
                    .fill(Color.difficultyColor(for: sentence.difficulty))
                    .frame(width: 6, height: 6)
            }
        }
    }

    // MARK: - Layer 0: English Sentence

    private func englishSentence(_ sentence: AnalyzedSentence, index: Int, phase: CardPhase) -> some View {
        Group {
            if phase >= .comprehension {
                // Grammar-colored text
                buildColorCodedText(sentence)
                    .studySentenceStyle()
                    .accessibilityLabel("영어 문장: \(sentence.original)")
            } else {
                // Plain text
                Text(sentence.original)
                    .studySentenceStyle()
                    .foregroundStyle(.primary)
                    .accessibilityLabel("영어 문장: \(sentence.original)")
            }
        }
    }

    // MARK: - Layer 1: Comprehension

    private func comprehensionLayer(_ sentence: AnalyzedSentence, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Korean translation
            Text(sentence.translation)
                .studyTranslationStyle()
                .padding(.bottom, StudyLayout.spacingSM)
                .accessibilityLabel("번역: \(sentence.translation)")

            // Self-assessment icons
            selfAssessmentRow(index: index)
                .padding(.bottom, StudyLayout.spacingBase)

            // Phrase translation
            if let alignment = sentence.koreanAlignment, !alignment.isEmpty {
                phraseSection(alignment)
                    .padding(.bottom, StudyLayout.spacingBase)
            }

            // Deep dive hint (when not yet in deep dive)
            if phase(for: index) < .deepDive {
                HStack(spacing: 4) {
                    Text("자세히")
                        .font(.caption2)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundStyle(.quaternary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, StudyLayout.spacingSM)
            }
        }
    }

    // MARK: - Self Assessment

    private func selfAssessmentRow(index: Int) -> some View {
        HStack(spacing: 12) {
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if flaggedSentences.contains(index) {
                        flaggedSentences.remove(index)
                        onFlagSentence(index, false)
                    }
                }
                hapticLight.impactOccurred()
            } label: {
                Image(systemName: flaggedSentences.contains(index) ? "checkmark.circle" : "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(flaggedSentences.contains(index) ? Color.secondary : Color.green.opacity(0.6))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("이해했어요")

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if flaggedSentences.contains(index) {
                        flaggedSentences.remove(index)
                        onFlagSentence(index, false)
                    } else {
                        flaggedSentences.insert(index)
                        onFlagSentence(index, true)
                    }
                }
                hapticLight.impactOccurred()
            } label: {
                Image(systemName: flaggedSentences.contains(index) ? "questionmark.circle.fill" : "questionmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(flaggedSentences.contains(index) ? Color.dayreadGold : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("어려워요")
        }
    }

    // MARK: - Layer 2: Deep Dive

    private func deepDiveLayer(_ sentence: AnalyzedSentence, index: Int) -> some View {
        VStack(alignment: .leading, spacing: StudyLayout.spacingBase) {
            // Key vocabulary (expandable pills)
            if !sentence.vocabulary.isEmpty {
                vocabularySection(sentence.vocabulary, sentenceIndex: index)
            }

            // Expressions (expandable pills)
            if !sentence.expressions.isEmpty {
                expressionsSection(sentence.expressions, sentenceIndex: index)
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
        }
    }

    // MARK: - Tap Handler

    private func handleTap(index: Int) {
        let current = phase(for: index)
        guard current < .deepDive else { return }

        let next: CardPhase = current == .encounter ? .comprehension : .deepDive

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            cardPhases[index] = next
        }
        hapticSoft.impactOccurred()
    }

    // MARK: - Completion Card

    private var completionCard: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)

            Text("Immersive 읽기 완료!")
                .font(.title3.weight(.medium))

            // Summary
            VStack(spacing: 4) {
                Text("\(sentences.count)개 문장 읽기 완료")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !flaggedSentences.isEmpty {
                    Text("\(flaggedSentences.count)개 어려운 문장 표시됨")
                        .font(.caption)
                        .foregroundStyle(Color.dayreadGold)
                }
            }

            // Continue button
            Button {
                hapticMedium.impactOccurred()
                onAdvanceMode()
            } label: {
                Text("Focus 학습 시작")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.dayreadGold)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            hapticMedium.impactOccurred()
            if let s = sentences.last { onStudied(s.id) }
        }
    }

    // MARK: - Card Indicator

    private func cardIndicator(index: Int, phase: CardPhase) -> some View {
        HStack {
            Text("\(index + 1) / \(sentences.count)")
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.tertiary)

            Spacer()

            if phase < .comprehension {
                HStack(spacing: 4) {
                    Text("탭하여 확인")
                        .font(.caption2)
                }
                .foregroundStyle(.quaternary)
            } else if index < sentences.count - 1 {
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

        if newID > oldIndex, let s = sentences[safe: oldIndex] {
            onStudied(s.id)
        }

        hapticLight.impactOccurred()

        if newID >= sentences.count {
            sentenceIndex = sentences.count - 1
            return
        }

        sentenceIndex = newID
        expandedVocabId = nil
        onSentenceChange(newID)
    }

    // MARK: - Grammar Color Coding

    private func buildColorCodedText(_ sentence: AnalyzedSentence) -> Text {
        let segments = buildSegments(sentence)
        var result = Text("")
        for segment in segments {
            switch segment {
            case .plain(let text):
                result = result + Text(text)
            case .element(let element):
                let color = Color.grammarColor(for: element.role)
                let word = element.text.trimmingCharacters(in: .whitespaces)
                result = result + Text(word)
                    .foregroundColor(color)
                    .underline(color: color.opacity(0.4))
            }
        }
        return result
    }

    private enum TextSegment {
        case plain(String)
        case element(GrammarElement)
    }

    private func buildSegments(_ sentence: AnalyzedSentence) -> [TextSegment] {
        let original = sentence.original
        var segments: [TextSegment] = []
        var pos = original.startIndex

        for el in sentence.grammarElements {
            let trimmed = el.text.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if let range = original.range(of: trimmed, range: pos..<original.endIndex) {
                if range.lowerBound > pos {
                    segments.append(.plain(String(original[pos..<range.lowerBound])))
                }
                segments.append(.element(el))
                pos = range.upperBound
            }
        }
        if pos < original.endIndex {
            segments.append(.plain(String(original[pos...])))
        }
        return segments
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

    // MARK: - Vocabulary (Expandable)

    private func vocabularySection(_ vocabulary: [AnalyzedWord], sentenceIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: StudyLayout.spacingSM) {
            Text("핵심 단어")
                .studySectionHeaderStyle()

            VStack(spacing: 6) {
                ForEach(Array(vocabulary.prefix(6).enumerated()), id: \.offset) { _, v in
                    let isExpanded = expandedVocabId == v.word
                    VStack(alignment: .leading, spacing: 0) {
                        // Collapsed pill
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.difficultyColor(for: v.difficulty))
                                .frame(width: 5, height: 5)
                            Text(v.word).fontWeight(.medium)
                            if !isExpanded {
                                Text("·").foregroundStyle(.tertiary)
                                Text(v.meaning).foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                            if isExpanded {
                                let isSaved = srsService.items.contains { $0.front == v.word }
                                Button {
                                    srsService.addItem(type: .vocabulary, front: v.word, back: v.meaning, source: "")
                                    hapticLight.impactOccurred()
                                } label: {
                                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                        .font(.caption)
                                        .foregroundStyle(Color.dayreadGold)
                                }
                                .buttonStyle(.plain)
                                .disabled(isSaved)
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                        // Expanded detail
                        if isExpanded {
                            VStack(alignment: .leading, spacing: 4) {
                                // POS + difficulty
                                HStack(spacing: 4) {
                                    Text(v.pos)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.quaternary)
                                        .clipShape(Capsule())
                                    Text(DifficultyLevel.label(for: v.difficulty))
                                        .font(.caption2)
                                        .foregroundStyle(v.difficulty >= 4 ? Color.dayreadGold : .secondary)
                                }

                                // Meaning
                                Text(v.meaning)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                // Example
                                if !v.example.isEmpty {
                                    HStack(spacing: 6) {
                                        Rectangle()
                                            .fill(Color.dayreadGold.opacity(0.2))
                                            .frame(width: 2)
                                        Text(v.example)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                            .italic()
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            expandedVocabId = isExpanded ? nil : v.word
                        }
                    }
                }
            }
        }
    }

    // MARK: - Expressions (Expandable)

    private func expressionsSection(_ expressions: [Expression], sentenceIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: StudyLayout.spacingSM) {
            Text("표현")
                .studySectionHeaderStyle()

            VStack(spacing: 6) {
                ForEach(Array(expressions.prefix(4).enumerated()), id: \.offset) { _, ex in
                    let isExpanded = expandedVocabId == "ex_\(ex.phrase)"
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Text(ex.phrase).fontWeight(.medium)
                            if !isExpanded {
                                Text("·").foregroundStyle(.tertiary)
                                Text(ex.meaning).foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                        if isExpanded {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ex.meaning)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(ex.usage)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                Text(ex.register.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.dayreadGold.opacity(0.08))
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                        }
                    }
                    .background(Color.dayreadGold.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            expandedVocabId = isExpanded ? nil : "ex_\(ex.phrase)"
                        }
                    }
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
