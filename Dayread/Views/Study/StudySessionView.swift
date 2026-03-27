import SwiftUI

// MARK: - View Mode

enum ViewMode: String, CaseIterable {
    case overview, immersive, focus, reoverview
}

private let studyStages: [ViewMode] = [.overview, .immersive, .focus, .reoverview]

// MARK: - Local Progress Persistence

private struct LocalStudyProgress: Codable {
    var stageIndex: Int
    var globalStep: Int
    var maxUnlockedStep: Int
    var sentenceIndex: Int?
}

private func loadLocalProgress(sessionId: String) -> LocalStudyProgress? {
    guard let data = UserDefaults.standard.data(forKey: "dayread-study-progress-\(sessionId)"),
          let saved = try? JSONDecoder().decode(LocalStudyProgress.self, from: data) else {
        return nil
    }
    return saved
}

private func saveLocalProgress(sessionId: String, progress: LocalStudyProgress) {
    if let data = try? JSONEncoder().encode(progress) {
        UserDefaults.standard.set(data, forKey: "dayread-study-progress-\(sessionId)")
    }
}

// MARK: - Study Session View

struct StudySessionView: View {
    let session: StudySession
    let sessionId: String
    let membershipTier: String
    let progressState: UserSessionProgressState
    let updateProgressState: ((inout UserSessionProgressState) -> Void, Bool) -> Void

    @Environment(TTSService.self) private var tts
    @Environment(StudyProgressService.self) private var progressService
    @Environment(\.dismiss) private var dismiss

    // Stage state
    @State private var viewMode: ViewMode = .overview
    @State private var stageIndex = 0
    @State private var globalStep = 0
    @State private var maxUnlockedStep = 0

    // Sentence state
    @State private var currentIndex = 0
    @State private var sentenceStates: [Int: SentenceLearningState] = [:]
    @State private var highlightIndex: Int? = nil

    // Auto-play
    @State private var autoPlayOnNav = false

    private var n: Int { session.sentences.count }
    private var totalSteps: Int { StudyStepUtils.computeTotalSteps(n) }
    private var sentenceTexts: [String] { session.sentences.map(\.original) }
    private var studiedCount: Int { progressState.studiedSentenceIds.count }

    init(session: StudySession, sessionId: String, membershipTier: String,
         progressState: UserSessionProgressState,
         updateProgressState: @escaping ((inout UserSessionProgressState) -> Void, Bool) -> Void) {
        self.session = session
        self.sessionId = sessionId
        self.membershipTier = membershipTier
        self.progressState = progressState
        self.updateProgressState = updateProgressState

        // Restore from local progress
        if let saved = loadLocalProgress(sessionId: sessionId) {
            _stageIndex = State(initialValue: saved.stageIndex)
            _viewMode = State(initialValue: studyStages[safe: saved.stageIndex] ?? .overview)
            _globalStep = State(initialValue: saved.globalStep)
            _maxUnlockedStep = State(initialValue: saved.maxUnlockedStep)
            _currentIndex = State(initialValue: saved.sentenceIndex ?? progressState.lastIndex)
        } else {
            _currentIndex = State(initialValue: progressState.lastIndex)
        }

        // Restore per-sentence states
        var states: [Int: SentenceLearningState] = [:]
        for (key, value) in progressState.sentenceStates {
            if let idx = Int(key) { states[idx] = value }
        }
        _sentenceStates = State(initialValue: states)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            // Progress bar
            HeaderProgressBarView(
                sentenceCount: n,
                currentStep: globalStep,
                maxUnlockedStep: maxUnlockedStep,
                onGoToStep: { step in
                    goToStep(step)
                }
            )

            // Body
            stageContent
        }
        .onChange(of: currentIndex) { _, newIndex in
            persistSentenceIndex(newIndex)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                // Title area
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        if session.overview.source != "Unknown" {
                            Text(session.overview.source)
                                .font(.caption2)
                                .textCase(.uppercase)
                                .tracking(1)
                                .foregroundStyle(Color.dayreadGold)
                        }
                        if viewMode == .immersive || viewMode == .focus {
                            Text("\(currentIndex + 1)/\(n)")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .monospacedDigit()
                        }
                    }
                    Text(session.overview.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Audio player
                FullTextPlayerView(
                    sentences: sentenceTexts,
                    currentIndex: currentIndex,
                    viewMode: viewMode,
                    onSentenceChange: { idx in navigateToSentence(idx) },
                    onPlayIndexChange: { idx in highlightIndex = idx },
                    maxUnlockedSentence: (viewMode == .immersive || viewMode == .focus) ? currentIndex : .max,
                    mode: (viewMode == .immersive || viewMode == .focus) ? .single : .continuous,
                    autoPlayOnNav: autoPlayOnNav,
                    onAutoPlayChange: { autoPlayOnNav = $0 }
                )
            }
            .padding(.horizontal, StudyLayout.pageHorizontal)
            .padding(.vertical, 6)
        }
        .background(.bar)
    }

    // MARK: - Stage Content

    @ViewBuilder
    private var stageContent: some View {
        switch viewMode {
        case .overview:
            StudyOverviewIntroView(
                sentences: session.sentences,
                sessionId: sessionId,
                highlightIndex: highlightIndex,
                onComplete: {
                    setMaxUnlockedStep(max(maxUnlockedStep, 2))
                    setGlobalStep(2)
                    advanceStage()
                }
            )

        case .immersive:
            ImmersiveView(
                sentences: session.sentences,
                initialIndex: currentIndex,
                onAdvanceMode: {
                    setMaxUnlockedStep(max(maxUnlockedStep, 2 + n))
                    setGlobalStep(2 + n)
                    advanceStage()
                },
                onSentenceChange: { idx in
                    goToSentence(idx)
                    persistLastIndex(idx)
                    setGlobalStep(2 + idx)
                    setMaxUnlockedStep(max(maxUnlockedStep, 2 + idx))
                },
                onStudied: { id in
                    markStudied(id)
                    progressService.recordStudy(sentenceCount: 1)
                }
            )

        case .focus:
            SentenceFocusView(
                sentences: session.sentences,
                currentIndex: currentIndex,
                sessionId: sessionId,
                getState: { getState($0) },
                onNavigate: { navigateToSentence($0) },
                onNext: {
                    let nextIdx = min(currentIndex + 1, n - 1)
                    handleFocusNext()
                    let focusBase = 2 + n
                    let nextStep = focusBase + nextIdx * 3
                    setGlobalStep(nextStep)
                    setMaxUnlockedStep(max(maxUnlockedStep, nextStep))
                },
                onPrev: { handleFocusPrev() },
                onUpdateStatus: { idx, status in
                    handleUpdateStatus(idx, status)
                },
                onExit: {
                    setMaxUnlockedStep(max(maxUnlockedStep, 2 + n + 3 * n))
                    setGlobalStep(2 + 4 * n)
                    advanceStage()
                }
            )
            .padding(.top, 16)

        case .reoverview:
            ScrollView {
                VStack(spacing: 0) {
                    StudyOverviewFinalView(
                        sentences: session.sentences,
                        overview: session.overview,
                        studiedCount: studiedCount,
                        getState: { getState($0) },
                        highlightIndex: highlightIndex
                    )

                    // 3-level summary viewer
                    if let summaries = session.summaries, !summaries.isEmpty {
                        SummaryLevelView(summaries: summaries)
                            .padding(.horizontal, StudyLayout.pageHorizontal)
                            .padding(.top, 8)
                    }

                    // Completion CTA
                    VStack(spacing: 8) {
                        Text("학습 완료!")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)
                        Text("수고하셨어요. 다음 학습자료를 시작해보세요.")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                        Button {
                            progressService.recordSession()
                            AnalyticsService.track("session_completed", properties: ["session_id": sessionId])
                            dismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Text("학습 목록으로 돌아가기")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.dayreadGold)
                            .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusMD))
                        }
                    }
                    .padding(.vertical, 32)
                }
            }
        }
    }

    // MARK: - Stage Management

    private func advanceStage() {
        let nextIdx = stageIndex + 1
        guard nextIdx < studyStages.count else { return }
        stageIndex = nextIdx
        viewMode = studyStages[nextIdx]
        if viewMode == .immersive || viewMode == .focus {
            goToSentence(0)
        }
    }

    private func goToStep(_ step: Int) {
        guard step <= maxUnlockedStep else { return }
        setGlobalStep(step)

        if step <= 1 {
            viewMode = .overview; stageIndex = 0
        } else if step < 2 + n {
            let si = step - 2
            viewMode = .immersive; stageIndex = 1
            goToSentence(min(si, n - 1))
        } else if step < 2 + n + 3 * n {
            let si = (step - 2 - n) / 3
            viewMode = .focus; stageIndex = 2
            goToSentence(min(si, n - 1))
        } else {
            viewMode = .reoverview; stageIndex = 3
        }
    }

    // MARK: - Sentence Management

    private func goToSentence(_ index: Int) {
        currentIndex = index
    }

    private func navigateToSentence(_ index: Int) {
        guard index >= 0, index < session.sentences.count, index != currentIndex else { return }
        goToSentence(index)
        persistLastIndex(index)
    }

    private func getState(_ index: Int) -> SentenceLearningState {
        sentenceStates[index] ?? .initial
    }

    private func handleUpdateStatus(_ index: Int, _ status: SentenceLearningStatus) {
        var state = getState(index)
        state.status = status
        sentenceStates[index] = state

        updateProgressState({ progress in
            progress.sentenceStates[String(index)] = state
        }, status != .new)

        if status != .new {
            markStudied(session.sentences[index].id)
        }
    }

    // MARK: - Focus Navigation

    private func handleFocusNext() {
        let nextIndex = min(session.sentences.count - 1, currentIndex + 1)
        guard nextIndex != currentIndex else { return }

        markStudied(session.sentences[currentIndex].id)
        progressService.recordStudy(sentenceCount: 1)
        navigateToSentence(nextIndex)
    }

    private func handleFocusPrev() {
        let nextIndex = max(0, currentIndex - 1)
        guard nextIndex != currentIndex else { return }
        navigateToSentence(nextIndex)
    }

    // MARK: - Progress Tracking

    private func markStudied(_ sentenceId: Int) {
        updateProgressState({ progress in
            if !progress.studiedSentenceIds.contains(sentenceId) {
                progress.studiedSentenceIds.append(sentenceId)
            }
        }, true)
    }

    private func persistLastIndex(_ index: Int) {
        updateProgressState({ progress in
            progress.lastIndex = index
        }, false)
    }

    // MARK: - Local Progress Persistence

    private func setGlobalStep(_ step: Int) {
        globalStep = step
        saveProgress()
    }

    private func setMaxUnlockedStep(_ step: Int) {
        maxUnlockedStep = step
        saveProgress()
    }

    private func persistSentenceIndex(_ index: Int) {
        saveProgress()
    }

    private func saveProgress() {
        saveLocalProgress(sessionId: sessionId, progress: LocalStudyProgress(
            stageIndex: stageIndex,
            globalStep: globalStep,
            maxUnlockedStep: maxUnlockedStep,
            sentenceIndex: currentIndex
        ))
    }
}
