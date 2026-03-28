import SwiftUI

enum LibrarySection: String, CaseIterable {
    case path = "학습 경로"
    case daily = "데일리"
    case topics = "토픽"
}

struct LibraryView: View {
    @Environment(LibraryService.self) private var libraryService
    @Environment(UserService.self) private var userService
    @Environment(NetworkMonitor.self) private var networkMonitor

    @State private var sectionTab: LibrarySection = .path
    @State private var showPaywall = false
    @State private var selectedSessionId: String? = nil

    private var membershipTier: MembershipTier {
        libraryService.membershipTier
    }

    private var sessionMap: [String: StudySessionListItem] {
        Dictionary(uniqueKeysWithValues: libraryService.hydratedSessions.map { ($0.id, $0) })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !networkMonitor.isConnected {
                    HStack(spacing: 6) {
                        Image(systemName: "wifi.slash")
                        Text("오프라인 모드 — 저장된 데이터를 표시합니다")
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                }

                // Segmented picker
                Picker("섹션", selection: $sectionTab) {
                    ForEach(LibrarySection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch sectionTab {
                case .path:
                    pathSection
                case .daily:
                    DailyPremiumView(
                        onSessionTap: { sessionId in
                            selectedSessionId = sessionId
                        },
                        onShowPaywall: { showPaywall = true }
                    )
                    .padding(.horizontal)
                case .topics:
                    topicsSection
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("학습")
        .navigationDestination(item: $selectedSessionId) { sessionId in
            SessionDetailPage(sessionId: sessionId)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView {
                Task {
                    await libraryService.reloadLibrary()
                    await userService.loadProfile()
                }
            }
        }
        .refreshable {
            await libraryService.reloadLibrary()
        }
        .task {
            if libraryService.summariesStatus == .idle {
                await libraryService.loadSummaries()
            }
        }
    }

    // MARK: - Path Section

    private var pathSection: some View {
        VStack(spacing: 20) {
            if libraryService.summariesStatus == .loading {
                ProgressView()
                    .padding(.top, 40)
            } else if libraryService.summariesStatus == .error && libraryService.sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("콘텐츠를 불러올 수 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("아래로 당겨서 다시 시도하세요")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.top, 40)
            }

            // Week sections
            ForEach(1...CurriculumUtils.maxLiveWeek, id: \.self) { weekNumber in
                let weekSessions = weekSessionsFor(weekNumber)
                if let weekMeta = CurriculumUtils.getWeekData(weekNumber), !weekSessions.isEmpty {
                    WeekSectionView(
                        weekNumber: weekNumber,
                        weekMeta: weekMeta,
                        sessions: weekSessions,
                        membershipTier: membershipTier,
                        isFreeWeek: weekNumber <= CurriculumContent.freeWeekLimit,
                        onSessionTap: handleSessionTap,
                        onSessionAppear: { sessionId in
                            libraryService.prefetchSession(sessionId: sessionId)
                        }
                    )
                    .padding(.horizontal)
                }
            }

            // Legacy sessions
            let legacySessions = SessionAccess.getLegacySessions(libraryService.hydratedSessions)
            if !legacySessions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("보너스 레슨")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(legacySessions) { session in
                        SessionListItemView(
                            session: session,
                            membershipTier: membershipTier,
                            onTap: { handleSessionTap(session) }
                        )
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    // MARK: - Topics Section

    private var topicsSection: some View {
        CollectionsListView(
            sessionMap: sessionMap,
            membershipTier: membershipTier,
            onSessionTap: handleSessionTap,
            onSessionAppear: { sessionId in
                libraryService.prefetchSession(sessionId: sessionId)
            }
        )
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func weekSessionsFor(_ weekNumber: Int) -> [StudySessionListItem] {
        let weekContent = CurriculumContent.getWeekContent(weekNumber)
        let sessionIds = Set(weekContent.compactMap(\.sessionId))
        return libraryService.hydratedSessions.filter { sessionIds.contains($0.id) }
    }

    private func handleSessionTap(_ session: StudySessionListItem) {
        if SessionAccess.isSessionOpen(session) {
            selectedSessionId = session.id
        } else {
            showPaywall = true
        }
    }

}
