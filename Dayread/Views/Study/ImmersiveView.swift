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
    let sessionId: String
    let onAdvanceMode: () -> Void
    let onSentenceChange: (Int) -> Void
    let onStudied: (Int) -> Void
    let onFlagSentence: (Int, Bool) -> Void

    @Environment(SRSService.self) private var srsService
    @State private var scrolledID: Int?
    @State private var sentencePhases: [Int: LearningPhase] = [:]
    @State private var flaggedSentences: Set<Int> = []

    init(sentences: [AnalyzedSentence], initialIndex: Int,
         sessionId: String = "",
         onAdvanceMode: @escaping () -> Void,
         onSentenceChange: @escaping (Int) -> Void,
         onStudied: @escaping (Int) -> Void,
         onFlagSentence: @escaping (Int, Bool) -> Void = { _, _ in }) {
        self.sentences = sentences
        self.initialIndex = initialIndex
        self.sessionId = sessionId
        self.onAdvanceMode = onAdvanceMode
        self.onSentenceChange = onSentenceChange
        self.onStudied = onStudied
        self.onFlagSentence = onFlagSentence
        _scrolledID = State(initialValue: initialIndex)
    }

    private var currentIndex: Int { scrolledID ?? 0 }

    var body: some View {
        Group {
            if currentIndex >= sentences.count {
                ImmersiveCompletionCard(
                    count: sentences.count,
                    onAction: onAdvanceMode
                )
            } else {
                SentencePagingPage(
                    sentence: sentences[currentIndex],
                    index: currentIndex,
                    totalCount: sentences.count,
                    phase: sentencePhases[currentIndex] ?? .original,
                    isFlagged: flaggedSentences.contains(currentIndex),
                    sessionId: sessionId,
                    onPhaseChange: { newPhase in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            sentencePhases[currentIndex] = newPhase
                        }
                        HapticsService.shared.soft()
                    },
                    onNextSentence: { goToNextSentence() },
                    onFlag: { isFlag in
                        if isFlag { flaggedSentences.insert(currentIndex) }
                        else { flaggedSentences.remove(currentIndex) }
                        onFlagSentence(currentIndex, isFlag)
                        HapticsService.shared.light()
                    }
                )
                .id(currentIndex)
                .transition(.push(from: .bottom))
            }
        }
        .background(Color(.systemBackground))
        .animation(.easeInOut(duration: 0.4), value: scrolledID)
        .task(id: initialIndex) {
            if scrolledID != initialIndex {
                scrolledID = initialIndex
            }
        }
    }

    private func goToNextSentence() {
        let oldIndex = currentIndex
        if oldIndex < sentences.count {
            onStudied(sentences[oldIndex].id)
        }
        if oldIndex < sentences.count - 1 {
            scrolledID = oldIndex + 1
            onSentenceChange(oldIndex + 1)
        } else {
            scrolledID = sentences.count
        }
        HapticsService.shared.light()
    }
}

// MARK: - Sentence Paging Page

fileprivate struct SentencePagingPage: View {
    let sentence: AnalyzedSentence
    let index: Int
    let totalCount: Int
    let phase: LearningPhase
    let isFlagged: Bool
    let sessionId: String
    let onPhaseChange: (LearningPhase) -> Void
    let onNextSentence: () -> Void
    let onFlag: (Bool) -> Void

    @Environment(SRSService.self) private var srsService
    @State private var activeGrammarIdx: Int? = nil
    @State private var arrowBounce = false

    var body: some View {
        VStack(spacing: 0) {
            fixedHeaderSection

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        if phase == .chunks {
                            phraseAlignmentSection
                                .staggeredAppear(delay: 0.1)
                                .id("chunks")
                        }

                        if phase == .fullTranslation {
                            fullTranslationSection
                                .staggeredAppear(delay: 0.1)
                                .id("full")
                        }

                        if phase == .deepDive {
                            deepDiveSection
                                .staggeredAppear(delay: 0.1)
                                .id("deep")
                        }

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, StudyLayout.pageHorizontal)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: phase) { _, newPhase in
                        activeGrammarIdx = nil
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
            }

            hintBar
        }
        .background(
            Color.dayreadGold.opacity(0.02)
                .ignoresSafeArea()
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    let dy = value.translation.height
                    let totalDist = abs(dy) + abs(value.translation.width)

                    if totalDist < 10 {
                        // Tap — advance phase (non-deepDive only)
                        if phase < .deepDive { advancePhase() }
                    } else if dy > 150 && value.velocity.height > 800 {
                        // Swipe down — retreat to previous phase
                        retreatPhase()
                    } else if phase == .deepDive && dy < -150 && value.velocity.height < -1200 {
                        // Strong swipe up in deepDive — next sentence
                        onNextSentence()
                    }
                }
        )
    }

    private func advancePhase() {
        if phase == .original {
            onPhaseChange(.chunks)
        } else if phase == .chunks {
            onPhaseChange(.fullTranslation)
        } else if phase == .fullTranslation {
            onPhaseChange(.deepDive)
        }
        // deepDive: swipe only for next sentence
    }

    private func retreatPhase() {
        if phase == .chunks {
            onPhaseChange(.original)
        } else if phase == .fullTranslation {
            onPhaseChange(.chunks)
        } else if phase == .deepDive {
            onPhaseChange(.fullTranslation)
        }
    }

    // MARK: - Sections

    private var sentenceSaved: Bool {
        srsService.isSaved(front: sentence.original, type: .sentence)
    }

    private var fixedHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SENTENCE \(index + 1)")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button {
                    srsService.toggleSave(
                        type: .sentence,
                        front: sentence.original,
                        back: sentence.translation,
                        source: sessionId
                    )
                    HapticsService.shared.light()
                } label: {
                    Image(systemName: sentenceSaved ? "checkmark.circle.fill" : "plus.circle")
                        .font(.body)
                        .foregroundStyle(sentenceSaved ? Color.dayreadGold : Color.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 16)

            // Grammar role labels + color-coded text in deepDive
            if phase == .deepDive {
                buildColorCodedText(sentence)
                    .studySentenceStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)

                FlowLayout(spacing: 6) {
                    ForEach(Array(sentence.grammarElements.enumerated()), id: \.offset) { idx, el in
                        let isActive = activeGrammarIdx == idx
                        HStack(spacing: 3) {
                            Text(el.role.label)
                                .fontWeight(.bold)
                            Text(el.role.labelKo)
                        }
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.grammarColor(for: el.role))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.grammarBgColor(for: el.role))
                        .overlay(
                            Capsule()
                                .stroke(Color.grammarColor(for: el.role), lineWidth: isActive ? 1.5 : 0)
                        )
                        .clipShape(Capsule())
                        .scaleEffect(isActive ? 1.05 : 1.0)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                activeGrammarIdx = activeGrammarIdx == idx ? nil : idx
                            }
                        }
                    }
                }
            } else {
                Text(sentence.original)
                    .studySentenceStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
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

    /// Vocabulary filtered to exclude words already covered by expressions
    private var filteredVocabulary: [AnalyzedWord] {
        let exprPhrases = sentence.expressions.map { $0.phrase.lowercased() }
        return sentence.vocabulary.filter { vocab in
            !exprPhrases.contains { $0.contains(vocab.word.lowercased()) }
        }
    }

    private var deepDiveSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 핵심 표현 (Expressions)
            if !sentence.expressions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("핵심 표현")
                        .studySectionHeaderStyle()

                    ForEach(sentence.expressions) { expr in
                        ExpressionPill(expression: expr, sessionId: sessionId)
                    }
                }
            }

            // 핵심 단어 (Vocabulary) — deduplicated
            if !filteredVocabulary.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("핵심 단어")
                        .studySectionHeaderStyle()

                    ForEach(filteredVocabulary.prefix(3)) { vocab in
                        VocabPill(vocab: vocab, sessionId: sessionId)
                    }
                }
            }

            // Flag
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

    // MARK: - Hint Bar

    @ViewBuilder
    private var hintBar: some View {
        if phase == .deepDive {
            // Swipe-only zone with animated arrow
            VStack(spacing: 8) {
                Image(systemName: "chevron.up")
                    .font(.caption)
                    .offset(y: arrowBounce ? -4 : 2)
                Image(systemName: "chevron.up")
                    .font(.caption.weight(.medium))
                    .offset(y: arrowBounce ? -4 : 2)

                Text(index < totalCount - 1 ? "올려서 다음 문장 보기" : "올려서 완료")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
            }
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    arrowBounce = true
                }
            }
            .onDisappear { arrowBounce = false }
        } else {
            // Tap hint for phase advance
            VStack(spacing: 6) {
                Image(systemName: "chevron.compact.up")
                    .font(.title3)
                Text(hintText)
                    .font(.caption2.weight(.bold))
                    .tracking(1)
            }
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    private var hintText: String {
        switch phase {
        case .original: return "탭하여 구 단위 번역 보기"
        case .chunks: return "탭하여 전체 번역 보기"
        case .fullTranslation: return "탭하여 핵심 표현 보기"
        case .deepDive: return ""
        }
    }

    private func buildColorCodedText(_ sentence: AnalyzedSentence) -> Text {
        let original = sentence.original

        // Independent matching — handles out-of-order grammar elements
        struct Match { let range: Range<String.Index>; let idx: Int }
        var matches: [Match] = []
        var usedRanges: [Range<String.Index>] = []

        for (idx, el) in sentence.grammarElements.enumerated() {
            let trimmed = el.text.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            var searchStart = original.startIndex
            while searchStart < original.endIndex {
                guard let range = original.range(of: trimmed, range: searchStart..<original.endIndex) else { break }
                let overlaps = usedRanges.contains { $0.lowerBound < range.upperBound && $0.upperBound > range.lowerBound }
                if !overlaps {
                    matches.append(Match(range: range, idx: idx))
                    usedRanges.append(range)
                    break
                }
                searchStart = range.upperBound
            }
        }

        matches.sort { $0.range.lowerBound < $1.range.lowerBound }

        var result = Text("")
        var pos = original.startIndex
        let dimColor: Color = .primary

        for match in matches {
            if match.range.lowerBound < pos { continue }
            if match.range.lowerBound > pos {
                result = result + Text(original[pos..<match.range.lowerBound])
                    .foregroundColor(activeGrammarIdx != nil ? dimColor : .primary)
            }
            let el = sentence.grammarElements[match.idx]
            let color = Color.grammarColor(for: el.role)
            if let active = activeGrammarIdx {
                if active == match.idx {
                    result = result + Text(original[match.range])
                        .foregroundColor(color)
                        .underline(color: color)
                        .bold()
                } else {
                    result = result + Text(original[match.range])
                        .foregroundColor(dimColor)
                }
            } else {
                result = result + Text(original[match.range])
                    .foregroundColor(color)
                    .underline(color: color.opacity(0.3))
            }
            pos = match.range.upperBound
        }

        if pos < original.endIndex {
            result = result + Text(original[pos...])
                .foregroundColor(activeGrammarIdx != nil ? dimColor : .primary)
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
                
                Text("\(count)개의 문장을 읽었습니다.\n더 깊이 읽어볼까요?")
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
                    Text("더 깊게 읽기")
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

// MARK: - Expression Pill

fileprivate struct ExpressionPill: View {
    let expression: Expression
    let sessionId: String
    @Environment(SRSService.self) private var srsService

    private var isSaved: Bool {
        srsService.isSaved(front: expression.phrase, type: .expression)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(expression.phrase)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button {
                    srsService.toggleSave(
                        type: .expression,
                        front: expression.phrase,
                        back: expression.meaning,
                        source: sessionId
                    )
                    HapticsService.shared.light()
                } label: {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                        .font(.body)
                        .foregroundStyle(isSaved ? Color.dayreadGold : Color.gray)
                }
                .buttonStyle(.plain)
            }

            Text(expression.meaning)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !expression.usage.isEmpty {
                Text(expression.usage)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Vocab Pill

fileprivate struct VocabPill: View {
    let vocab: AnalyzedWord
    let sessionId: String
    @Environment(SRSService.self) private var srsService

    private var isSaved: Bool {
        srsService.isSaved(front: vocab.word, type: .vocabulary)
    }

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
                Button {
                    srsService.toggleSave(
                        type: .vocabulary,
                        front: vocab.word,
                        back: vocab.meaning,
                        source: sessionId
                    )
                    HapticsService.shared.light()
                } label: {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                        .font(.body)
                        .foregroundStyle(isSaved ? Color.dayreadGold : Color.gray)
                }
                .buttonStyle(.plain)
            }

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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
