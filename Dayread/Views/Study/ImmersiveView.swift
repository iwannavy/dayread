import SwiftUI

// MARK: - Sentence Learning Phase

fileprivate enum LearningPhase: Int, Comparable, CaseIterable {
    case original = 0
    case chunks = 1
    case fullTranslation = 2
    case deepDive = 3

    static func < (lhs: LearningPhase, rhs: LearningPhase) -> Bool {
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
    @State private var scrolledID: Int?
    @State private var sentencePhases: [Int: LearningPhase] = [:]
    @State private var flaggedSentences: Set<Int> = []
    
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
        _scrolledID = State(initialValue: initialIndex)
    }

    var body: some View {
        GeometryReader { fullGeo in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sentences.enumerated()), id: \.offset) { idx, sentence in
                        SentencePagingPage(
                            sentence: sentence,
                            index: idx,
                            totalCount: sentences.count,
                            phase: sentencePhases[idx] ?? .original,
                            isFlagged: flaggedSentences.contains(idx),
                            onPhaseChange: { newPhase in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    sentencePhases[idx] = newPhase
                                }
                                HapticsService.shared.soft()
                            },
                            onNextSentence: {
                                if idx < sentences.count - 1 {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        scrolledID = idx + 1
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        scrolledID = sentences.count // Final card
                                    }
                                }
                            },
                            onFlag: { isFlag in
                                if isFlag { flaggedSentences.insert(idx) }
                                else { flaggedSentences.remove(idx) }
                                onFlagSentence(idx, isFlag)
                                HapticsService.shared.light()
                            }
                        )
                        .frame(width: fullGeo.size.width, height: fullGeo.size.height)
                        .id(idx)
                    }

                    // Completion Card
                    ImmersiveCompletionCard(
                        count: sentences.count,
                        onAction: onAdvanceMode
                    )
                    .frame(width: fullGeo.size.width, height: fullGeo.size.height)
                    .id(sentences.count)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrolledID)
            .onChange(of: scrolledID) { old, new in
                if let new, new < sentences.count {
                    onSentenceChange(new)
                    if let old, old < sentences.count {
                        onStudied(sentences[old].id)
                    }
                    HapticsService.shared.light()
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Sentence Paging Page

fileprivate struct SentencePagingPage: View {
    let sentence: AnalyzedSentence
    let index: Int
    let totalCount: Int
    let phase: LearningPhase
    let isFlagged: Bool
    let onPhaseChange: (LearningPhase) -> Void
    let onNextSentence: () -> Void
    let onFlag: (Bool) -> Void

    @State private var expandedVocabId: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            // 1. Header & Fixed Original
            fixedHeaderSection
            
            // 2. Scrollable Detail Area
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Phase 1: Phrase Alignment (Chunking)
                        if phase >= .chunks {
                            phraseAlignmentSection
                                .staggeredAppear(delay: 0.1)
                                .id("chunks")
                        }
                        
                        // Phase 2: Full Translation
                        if phase >= .fullTranslation {
                            fullTranslationSection
                                .staggeredAppear(delay: 0.1)
                                .id("full")
                        }
                        
                        // Phase 3: Deep Dive
                        if phase >= .deepDive {
                            deepDiveSection
                                .staggeredAppear(delay: 0.1)
                                .id("deep")
                        }
                        
                        // reveal Hint or Spacer
                        revealHintView
                            .id("hint")
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, StudyLayout.pageHorizontal)
                    .padding(.top, 16)
                    .onChange(of: phase) { _, newPhase in
                        withAnimation {
                            switch newPhase {
                            case .chunks: proxy.scrollTo("chunks", anchor: .top)
                            case .fullTranslation: proxy.scrollTo("full", anchor: .top)
                            case .deepDive: proxy.scrollTo("deep", anchor: .top)
                            default: break
                            }
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .simultaneousGesture(
                    DragGesture().onEnded { value in
                        if value.translation.height < -40 { // Swipe Up
                            advancePhase()
                        }
                    }
                )
            }
        }
        .background(
            Color.dayreadGold.opacity(0.02)
                .ignoresSafeArea()
        )
    }

    private func advancePhase() {
        if phase == .original {
            onPhaseChange(.chunks)
        } else if phase == .chunks {
            onPhaseChange(.fullTranslation)
        } else if phase == .fullTranslation {
            onPhaseChange(.deepDive)
        } else if phase == .deepDive {
            // Already at max phase, wait for global scroll to handle next sentence
            // or we could trigger onNextSentence() if we want it to be buttonless
        }
    }

    // MARK: - Sections

    private var fixedHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Progress Bar
            HStack(spacing: 4) {
                ForEach(0..<totalCount, id: \.self) { i in
                    Capsule()
                        .fill(i <= index ? Color.dayreadGold : Color.dayreadGold.opacity(0.15))
                        .frame(height: 3)
                }
            }
            .padding(.top, 16)
            
            HStack {
                Text("SENTENCE \(index + 1)")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                difficultyBadge
            }
            
            // The Fixed Original English
            Group {
                if phase >= .deepDive {
                    buildColorCodedText(sentence)
                        .studySentenceStyle()
                } else {
                    Text(sentence.original)
                        .studySentenceStyle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                advancePhase()
            }
        }
        .padding(.horizontal, StudyLayout.pageHorizontal)
        .padding(.bottom, 20)
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
        )
    }

    private var phraseAlignmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("구 단위 번역")
                .studySectionHeaderStyle()
            
            if let alignment = sentence.koreanAlignment {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(alignment.enumerated()), id: \.offset) { _, chunk in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chunk.en)
                                .font(.system(.subheadline, design: .serif))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.dayreadGold)
                            
                            Text(chunk.ko)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)
                        .overlay(
                            Rectangle()
                                .fill(Color.dayreadGold.opacity(0.2))
                                .frame(width: 2),
                            alignment: .leading
                        )
                    }
                }
            } else {
                Text("구 단위 데이터가 없습니다.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var fullTranslationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("전체 번역")
                .studySectionHeaderStyle()
            
            Text(sentence.translation)
                .studyTranslationStyle()
                .foregroundStyle(.primary)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.dayreadGold.opacity(0.05))
                )
        }
    }

    private var deepDiveSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Vocab
            if !sentence.vocabulary.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("핵심 표현")
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
            
            // Grammar
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
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.dayreadGold.opacity(0.15), lineWidth: 1)
                )
            }
            
            // Flag/Study
            HStack {
                Spacer()
                Button {
                    onFlag(!isFlagged)
                } label: {
                    Label(isFlagged ? "저장됨" : "중요 표시", systemImage: isFlagged ? "questionmark.circle.fill" : "questionmark.circle")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isFlagged ? Color.dayreadGold : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.dayreadGold.opacity(0.08)))
                }
            }
        }
    }

    private var revealHintView: some View {
        VStack(spacing: 8) {
            if phase < .deepDive {
                Image(systemName: "chevron.compact.up")
                    .font(.title2)
                Text(hintText)
                    .font(.caption2.weight(.bold))
                    .tracking(1)
            } else {
                Text("다음 문장으로 넘어가려면 위로 스와이프")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 20)
            }
        }
        .foregroundStyle(.tertiary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private var hintText: String {
        switch phase {
        case .original: return "위로 밀어서 구 단위 번역 보기"
        case .chunks: return "위로 밀어서 전체 번역 보기"
        case .fullTranslation: return "위로 밀어서 문장 상세 분석"
        default: return ""
        }
    }

    private var difficultyBadge: some View {
        Text(DifficultyLevel.label(for: sentence.difficulty))
            .font(.system(size: 9, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(CurriculumUtils.difficultyColor(sentence.difficulty).opacity(0.1))
            .foregroundStyle(CurriculumUtils.difficultyColor(sentence.difficulty))
            .clipShape(Capsule())
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

// MARK: - Completion Card (Subcomponent)

struct ImmersiveCompletionCard: View {
    let count: Int
    let onAction: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.dayreadGold.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.dayreadGold)
            }
            
            VStack(spacing: 12) {
                Text("읽기 완료!")
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.bold)
                
                Text("\(count)개의 문장을 깊이 있게 읽었습니다.\n이제 Focus 학습을 시작해볼까요?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Button {
                HapticsService.shared.medium()
                onAction()
            } label: {
                HStack(spacing: 8) {
                    Text("Focus 학습 시작")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 18)
                .background(Color.dayreadGold)
                .clipShape(Capsule())
                .shadow(color: Color.dayreadGold.opacity(0.3), radius: 15, y: 8)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .background(Color(.systemBackground))
        .onAppear {
            HapticsService.shared.success()
        }
    }
}

// MARK: - Vocab Pill

fileprivate struct VocabPill: View {
    let vocab: AnalyzedWord
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(vocab.word)
                    .font(.subheadline.weight(.semibold))
                Text(vocab.pos)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            if isExpanded {
                Text(vocab.meaning)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !vocab.example.isEmpty {
                    Text(vocab.example)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .italic()
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
