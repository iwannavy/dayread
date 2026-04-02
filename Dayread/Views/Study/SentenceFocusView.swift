import SwiftUI

struct SentenceFocusView: View {
    let sentences: [AnalyzedSentence]
    let currentIndex: Int
    var sessionId: String = ""
    let getState: (Int) -> SentenceLearningState
    let onNavigate: (Int) -> Void
    let onNext: () -> Void
    let onPrev: () -> Void
    let onUpdateStatus: (Int, SentenceLearningStatus) -> Void
    let onExit: () -> Void

    @State private var swipeOffset: CGFloat = 0
    @State private var swipeTriggered = false
    @State private var translationDone: Set<Int> = []
    @State private var dictationDone: Set<Int> = []
    private let hapticLight = UIImpactFeedbackGenerator(style: .light)
    private let hapticMedium = UIImpactFeedbackGenerator(style: .medium)

    private var sentence: AnalyzedSentence? { sentences[safe: currentIndex] }
    private var isLastSentence: Bool { currentIndex >= sentences.count - 1 }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if let sentence {
                    VStack(alignment: .leading, spacing: 0) {
                        // Previous sentences context
                        previousSentences
                            .id("focusTop")

                        // Grammar visualization
                        grammarSection(sentence)
                            .id(currentIndex)

                        // Analysis section
                        VStack(alignment: .leading, spacing: 0) {
                            SentenceAnalysisView(sentence: sentence, sessionId: sessionId)
                        }
                        .padding(.bottom, 24)

                        // Listen & Repeat
                        VStack(alignment: .leading, spacing: 8) {
                            Text("번역하고 받아쓰기")
                                .studySectionHeaderStyle()

                            DictationModeView(
                                sentence: sentence.original,
                                translation: sentence.translation,
                                translationDone: translationDone.contains(currentIndex),
                                dictationDone: dictationDone.contains(currentIndex),
                                onComplete: { score in
                                    if score >= 70 {
                                        onUpdateStatus(currentIndex, .listened)
                                    }
                                },
                                onModeComplete: { mode, _ in
                                    if mode == .translation {
                                        translationDone.insert(currentIndex)
                                    } else {
                                        dictationDone.insert(currentIndex)
                                    }
                                }
                            )
                            .id(currentIndex)
                            .padding(StudyLayout.cardPadding)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))
                        }
                        .padding(.bottom, 24)

                        // Swipe-up navigation zone
                        swipeUpZone
                    }
                    .padding(.horizontal, StudyLayout.pageHorizontal)
                }
            }
            .onChange(of: currentIndex) { _, _ in
                swipeOffset = 0
                swipeTriggered = false
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("focusTop", anchor: .top)
                }
            }
        }
    }

    // MARK: - Previous Sentences

    @ViewBuilder
    private var previousSentences: some View {
        let prevSlice = Array(sentences.prefix(currentIndex).suffix(3))
        if !prevSlice.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(prevSlice.enumerated()), id: \.offset) { i, s in
                    Text(s.original)
                        .studyContextStyle()
                        .opacity(0.3 + Double(i) / max(Double(prevSlice.count), 1) * 0.4)
                        .onTapGesture { onNavigate(currentIndex - prevSlice.count + i) }
                }
            }
            .padding(.bottom, 16)
        }
    }

    // MARK: - Grammar Section

    private func grammarSection(_ sentence: AnalyzedSentence) -> some View {
        GrammarVizView(
            elements: sentence.grammarElements,
            translation: sentence.translation,
            original: sentence.original,
            koreanAlignment: sentence.koreanAlignment,
            notes: sentence.notes,
            rhetoricalDevice: sentence.rhetoricalDevice
        )
        .padding(StudyLayout.cardPaddingLarge)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusLG))
        .padding(.bottom, StudyLayout.spacingBase)
    }

    // MARK: - Swipe-Up Navigation Zone

    private var swipeUpZone: some View {
        VStack(spacing: StudyLayout.spacingSM) {
            Text("\(currentIndex + 1) / \(sentences.count)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .monospacedDigit()

            if isLastSentence {
                Text("Focus 학습 완료!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
                Text("마지막으로 전체 글을 복습합니다")
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

                Text(isLastSentence ? "스와이프하여 복습 단계로" : "스와이프하여 다음 문장")
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
                            onExit()
                        } else {
                            onNext()
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

}
