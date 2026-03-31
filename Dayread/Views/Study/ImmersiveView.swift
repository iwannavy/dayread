import SwiftUI

// MARK: - Card Phase

fileprivate enum CardPhase: Int, Comparable, CaseIterable {
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
                    SentenceFullscreenPage(
                        sentence: sentence,
                        index: idx,
                        totalCount: sentences.count,
                        phase: phase(for: idx),
                        isFlagged: flaggedSentences.contains(idx),
                        expandedVocabId: $expandedVocabId,
                        onPhaseChange: { nextPhase in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                cardPhases[idx] = nextPhase
                            }
                            HapticsService.shared.soft()
                        },
                        onFlag: { isFlag in
                            if isFlag { flaggedSentences.insert(idx) }
                            else { flaggedSentences.remove(idx) }
                            onFlagSentence(idx, isFlag)
                            HapticsService.shared.light()
                        }
                    )
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
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Completion Card

    private var completionCard: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.dayreadGold.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.dayreadGold)
            }

            VStack(spacing: 8) {
                Text("Immersive 읽기 완료!")
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.bold)
                
                Text("\(sentences.count)개 문장을 깊이 있게 읽었습니다")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                HapticsService.shared.medium()
                onAdvanceMode()
            } label: {
                HStack(spacing: 8) {
                    Text("Focus 학습 시작")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.dayreadGold)
                .clipShape(Capsule())
                .shadow(color: Color.dayreadGold.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.top, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            HapticsService.shared.success()
            if let s = sentences.last { onStudied(s.id) }
        }
    }

    private func handleCardChange(_ newID: Int?) {
        guard let newID, newID != sentenceIndex else { return }
        let oldIndex = sentenceIndex

        if newID > oldIndex, let s = sentences[safe: oldIndex] {
            onStudied(s.id)
        }

        HapticsService.shared.light()

        if newID >= sentences.count {
            sentenceIndex = sentences.count - 1
            return
        }

        sentenceIndex = newID
        expandedVocabId = nil
        onSentenceChange(newID)
    }
}

// MARK: - Sentence Fullscreen Page

fileprivate struct SentenceFullscreenPage: View {
    let sentence: AnalyzedSentence
    let index: Int
    let totalCount: Int
    let phase: CardPhase
    let isFlagged: Bool
    @Binding var expandedVocabId: String?
    let onPhaseChange: (CardPhase) -> Void
    let onFlag: (Bool) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Fixed Background Original Text
            VStack(spacing: 0) {
                fixedOriginalSection
                Spacer()
            }
            .zIndex(1)

            // Scrollable Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Spacer for the fixed top part
                    Color.clear
                        .frame(height: 220)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        if phase >= .comprehension {
                            comprehensionSection
                                .staggeredAppear(delay: 0.1)
                        } else {
                            revealHintView(text: "위로 밀어서 번역 보기", icon: "arrow.up")
                        }

                        if phase >= .deepDive {
                            deepDiveSection
                                .staggeredAppear(delay: 0.1)
                        } else if phase == .comprehension {
                            revealHintView(text: "위로 밀어서 심화 학습", icon: "arrow.up")
                        }
                        
                        // Final spacing to allow scrolling the reveal hint into view
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, StudyLayout.pageHorizontal)
                    .padding(.top, 20)
                }
            }
            .scrollBounceBehavior(.always)
            .simultaneousGesture(
                DragGesture().onEnded { value in
                    if value.translation.height < -50 { // Swipe Up
                        handleSwipeUp()
                    }
                }
            )
        }
        .background(Color(.systemBackground))
    }

    private func handleSwipeUp() {
        if phase == .encounter {
            onPhaseChange(.comprehension)
        } else if phase == .comprehension {
            onPhaseChange(.deepDive)
        }
    }

    // MARK: - Sections

    private var fixedOriginalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(index + 1) / \(totalCount)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                difficultyBadge
            }
            
            Group {
                if phase >= .comprehension {
                    buildColorCodedText(sentence)
                        .studySentenceStyle()
                } else {
                    Text(sentence.original)
                        .studySentenceStyle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, StudyLayout.pageHorizontal)
        .padding(.top, 20)
        .padding(.bottom, 30)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemBackground), Color(.systemBackground).opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var comprehensionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Translation Card
            VStack(alignment: .leading, spacing: 12) {
                Text("번역")
                    .studySectionHeaderStyle()
                
                Text(sentence.translation)
                    .studyTranslationStyle()
                    .foregroundStyle(.primary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.dayreadGold.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Interaction Row
            HStack(spacing: 16) {
                Spacer()
                
                actionButton(icon: isFlagged ? "questionmark.circle.fill" : "questionmark.circle", color: isFlagged ? .dayreadGold : .secondary) {
                    onFlag(!isFlagged)
                }
                
                actionButton(icon: "checkmark.circle.fill", color: .green.opacity(0.6)) {
                    // Already studied via scroll
                }
            }
        }
    }

    private var deepDiveSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            if !sentence.vocabulary.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("핵심 단어")
                        .studySectionHeaderStyle()
                    
                    ForEach(sentence.vocabulary.prefix(3)) { vocab in
                        VocabPill(vocab: vocab, isExpanded: expandedVocabId == vocab.word)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    expandedVocabId = expandedVocabId == vocab.word ? nil : vocab.word
                                }
                            }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("문장 구조")
                    .studySectionHeaderStyle()
                
                GrammarVizView(
                    elements: sentence.grammarElements,
                    translation: sentence.translation,
                    original: sentence.original,
                    hideOriginal: true,
                    allActive: true,
                    compact: true
                )
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.dayreadGold.opacity(0.15), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Components

    private var difficultyBadge: some View {
        Text(DifficultyLevel.label(for: sentence.difficulty))
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(CurriculumUtils.difficultyColor(sentence.difficulty).opacity(0.1))
            .foregroundStyle(CurriculumUtils.difficultyColor(sentence.difficulty))
            .clipShape(Capsule())
    }

    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(Circle().fill(color.opacity(0.1)))
        }
        .buttonStyle(.plain)
    }

    private func revealHintView(text: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(.quaternary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func buildColorCodedText(_ sentence: AnalyzedSentence) -> Text {
        let original = sentence.original
        var result = Text("")
        var pos = original.startIndex

        for el in sentence.grammarElements {
            let trimmed = el.text.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if let range = original.range(of: trimmed, range: pos..<original.endIndex) {
                if range.lowerBound > pos {
                    result = result + Text(original[pos..<range.lowerBound])
                }
                let color = Color.grammarColor(for: el.role)
                result = result + Text(original[range])
                    .foregroundColor(color)
                    .underline(color: color.opacity(0.3))
                pos = range.upperBound
            }
        }
        if pos < original.endIndex {
            result = result + Text(original[pos...])
        }
        return result
    }
}

struct VocabPill: View {
    let vocab: AnalyzedWord
    let isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(vocab.word)
                    .font(.system(.subheadline, design: .serif))
                    .fontWeight(.bold)
                
                if !isExpanded {
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(vocab.meaning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text(vocab.meaning)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    if !vocab.example.isEmpty {
                        Text(vocab.example)
                            .font(.system(.caption, design: .serif))
                            .italic()
                            .foregroundStyle(.secondary)
                            .padding(.leading, 10)
                            .overlay(
                                Rectangle()
                                    .fill(Color.dayreadGold.opacity(0.3))
                                    .frame(width: 2)
                                    .padding(.vertical, 2),
                                alignment: .leading
                            )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.dayreadGold.opacity(isExpanded ? 0.08 : 0.03))
        )
    }
}
