import SwiftUI

struct SessionDetailPage: View {
    let sessionId: String

    @Environment(LibraryService.self) private var libraryService
    @Environment(UserService.self) private var userService
    @Environment(\.dismiss) private var dismiss

    @State private var isLoading = true

    private var membershipTier: MembershipTier {
        libraryService.membershipTier
    }

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let session = libraryService.getSession(sessionId: sessionId) {
                let progressState = libraryService.getProgressState(sessionId: sessionId)
                StudySessionView(
                    session: session,
                    sessionId: sessionId,
                    membershipTier: membershipTier.rawValue,
                    progressState: progressState,
                    updateProgressState: { updater, _ in
                        libraryService.updateSessionProgress(sessionId: sessionId) { state in
                            var mutable = state
                            updater(&mutable)
                            return mutable
                        }
                    }
                )
            } else {
                errorView("세션을 찾을 수 없습니다.")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.body)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await loadSession()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("세션 로딩 중...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("돌아가기") { dismiss() }
                .font(.subheadline)
                .foregroundStyle(Color.dayreadGold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadSession() async {
        isLoading = true
        _ = await libraryService.ensureSession(sessionId: sessionId)
        isLoading = false
    }
}
