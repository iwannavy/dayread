import Foundation

/// Load status shared across services
enum LoadStatus: String {
    case idle, loading, ready, error
}

/// Port of src/contexts/StudyLibraryContext.tsx
/// 3-tier state management: summaries + progress + details
@MainActor @Observable
final class LibraryService {
    // MARK: - Tier 1: Summary rows

    private(set) var sessions: [StudySessionListItem] = []
    private(set) var membershipTier: MembershipTier = .free
    private(set) var summariesStatus: LoadStatus = .idle

    // MARK: - Tier 2: Progress rows (per-session)

    private var progressRows: [String: UserSessionProgressState] = [:]
    private var dirtyProgressIds: Set<String> = []

    // MARK: - Tier 3: Detail cache (lazy loaded)

    private var detailCache: [String: StudySession] = [:]
    private(set) var detailStatusById: [String: LoadStatus] = [:]

    // MARK: - In-flight request deduplication

    private var inFlightDetails: [String: Task<StudySession?, Never>] = [:]
    private var flushTimers: [String: Task<Void, Never>] = [:]

    // MARK: - Dependencies

    private let apiClient: APIClient
    private let bundledStore: BundledSessionStore

    // MARK: - Disk Cache Keys

    private static let cacheKeySessions = "dayread-library-summaries"
    private static let cacheKeyMembership = "dayread-library-membership"
    private static let cacheKeyProgress = "dayread-library-progress"

    init(apiClient: APIClient, bundledStore: BundledSessionStore = BundledSessionStore()) {
        self.apiClient = apiClient
        self.bundledStore = bundledStore
        restoreFromDiskCache()
    }

    // MARK: - Disk Cache

    private func restoreFromDiskCache() {
        if let data = UserDefaults.standard.data(forKey: Self.cacheKeySessions),
           let cached = try? JSONDecoder().decode([StudySessionListItem].self, from: data) {
            sessions = cached
        }
        if let raw = UserDefaults.standard.string(forKey: Self.cacheKeyMembership),
           let tier = MembershipTier(rawValue: raw) {
            membershipTier = tier
        }
        if let data = UserDefaults.standard.data(forKey: Self.cacheKeyProgress),
           let cached = try? JSONDecoder().decode([String: UserSessionProgressState].self, from: data) {
            progressRows = cached
        }
        if !sessions.isEmpty {
            summariesStatus = .ready
        }
    }

    private func persistToDiskCache() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: Self.cacheKeySessions)
        }
        UserDefaults.standard.set(membershipTier.rawValue, forKey: Self.cacheKeyMembership)
        if let data = try? JSONEncoder().encode(progressRows) {
            UserDefaults.standard.set(data, forKey: Self.cacheKeyProgress)
        }
    }

    // MARK: - Hydrated sessions (Tier 1 + Tier 2 merged)

    var hydratedSessions: [StudySessionListItem] {
        sessions.map { item in
            let progressState = progressRows[item.id] ?? item.progressState ?? .empty
            return StudySessionListItem(
                id: item.id,
                overview: item.overview,
                progress: item.progress,
                createdAt: item.createdAt,
                lastStudiedAt: progressState.lastStudiedAt ?? item.createdAt,
                updatedAt: item.updatedAt,
                summaries: item.summaries,
                access: item.access,
                progressState: progressState
            )
        }
        .sorted { $0.createdAt < $1.createdAt }
    }

    // MARK: - Tier 1: Load summaries

    func loadSummaries() async {
        guard summariesStatus != .loading else { return }
        summariesStatus = .loading

        do {
            let payload = try await apiClient.fetchLibrarySummaries()
            membershipTier = payload.membershipTier
            sessions = payload.sessions

            var nextProgressRows: [String: UserSessionProgressState] = [:]
            for session in payload.sessions {
                if let progressState = session.progressState {
                    nextProgressRows[session.id] = progressState
                }
            }
            progressRows = nextProgressRows
            summariesStatus = .ready
            persistToDiskCache()
        } catch {
            #if DEBUG
            print("[LibraryService] loadSummaries failed: \(error)")
            #endif
            if sessions.isEmpty {
                // Fall back to bundled manifest (guest mode / offline)
                loadBundledFallback()
            }
        }
    }

    /// Populate session list from bundled manifest when API is unavailable.
    private func loadBundledFallback() {
        let bundledSessions = bundledStore.buildSessionListItems()
        guard !bundledSessions.isEmpty else {
            summariesStatus = .error
            return
        }
        sessions = bundledSessions
        membershipTier = .free
        summariesStatus = .ready
    }

    func reloadLibrary() async {
        summariesStatus = .loading
        do {
            let payload = try await apiClient.fetchLibrarySummaries()
            membershipTier = payload.membershipTier
            sessions = payload.sessions

            var nextProgressRows: [String: UserSessionProgressState] = [:]
            for session in payload.sessions {
                if let progressState = session.progressState {
                    nextProgressRows[session.id] = progressState
                }
            }
            progressRows = nextProgressRows
            summariesStatus = .ready
            persistToDiskCache()
        } catch {
            #if DEBUG
            print("[LibraryService] reloadLibrary failed: \(error)")
            #endif
            summariesStatus = .error
        }
    }

    // MARK: - Tier 2: Progress

    func getProgressState(sessionId: String) -> UserSessionProgressState {
        progressRows[sessionId] ?? .empty
    }

    func updateSessionProgress(sessionId: String, updater: (UserSessionProgressState) -> UserSessionProgressState) {
        let base = progressRows[sessionId] ?? .empty
        let next = updater(base)

        progressRows[sessionId] = next
        dirtyProgressIds.insert(sessionId)
        scheduleFlush(sessionId: sessionId)
    }

    private func scheduleFlush(sessionId: String) {
        flushTimers[sessionId]?.cancel()

        flushTimers[sessionId] = Task { [weak self] in
            try? await Task.sleep(for: .seconds(15))

            guard !Task.isCancelled else { return }
            await self?.flushProgressRow(sessionId: sessionId)
        }
    }

    private func flushProgressRow(sessionId: String) async {
        guard let snapshot = progressRows[sessionId] else { return }

        do {
            let payload = try await apiClient.saveSessionProgress(sessionId: sessionId, progressState: snapshot)
            progressRows[sessionId] = payload.progressState
            if let access = payload.access {
                applyAccessUpdate(sessionId: sessionId, access: access)
            }
            dirtyProgressIds.remove(sessionId)
        } catch {
            #if DEBUG
            print("[LibraryService] flushProgressRow failed for \(sessionId): \(error)")
            #endif
        }
    }

    /// Flush all pending progress — call on scenePhase → background
    func flushPendingProgress() async {
        let pendingIds = dirtyProgressIds

        for (sessionId, timer) in flushTimers {
            timer.cancel()
            flushTimers[sessionId] = nil
        }

        await withTaskGroup(of: Void.self) { group in
            for sessionId in pendingIds {
                group.addTask { [weak self] in
                    await self?.flushProgressRow(sessionId: sessionId)
                }
            }
        }
    }

    // MARK: - Tier 3: Session detail

    func getSession(sessionId: String) -> StudySession? {
        detailCache[sessionId]
    }

    func ensureSession(sessionId: String) async -> StudySession? {
        // 1. Memory cache
        if let cached = detailCache[sessionId] {
            return cached
        }

        // 2. Bundled local session (mirrors web's getLocalStudySession())
        if let bundled = bundledStore.getSession(sessionId) {
            detailCache[sessionId] = bundled
            detailStatusById[sessionId] = .ready
            return bundled
        }

        // 3. API fallback (new content, premium daily, etc.)
        if let inFlight = inFlightDetails[sessionId] {
            return await inFlight.value
        }

        detailStatusById[sessionId] = .loading

        let task = Task<StudySession?, Never> { [weak self] in
            guard let self else { return nil }

            do {
                let payload = try await self.apiClient.fetchSessionDetail(id: sessionId)

                self.progressRows[sessionId] = payload.progressState
                if let access = payload.access {
                    self.applyAccessUpdate(sessionId: sessionId, access: access)
                }

                if let session = payload.session {
                    self.detailCache[sessionId] = session
                    self.detailStatusById[sessionId] = .ready
                    return session
                } else {
                    self.detailStatusById[sessionId] = .error
                    return nil
                }
            } catch {
                #if DEBUG
                print("[LibraryService] ensureSession failed for \(sessionId): \(error)")
                #endif
                self.detailStatusById[sessionId] = .error
                return nil
            }
        }

        inFlightDetails[sessionId] = task
        let result = await task.value
        inFlightDetails[sessionId] = nil
        return result
    }

    func prefetchSession(sessionId: String) {
        guard let summary = sessions.first(where: { $0.id == sessionId }),
              summary.access?.canOpen == true,
              summary.access?.category != .premium else {
            return
        }

        Task {
            _ = await ensureSession(sessionId: sessionId)
        }
    }

    /// Pre-cache a session directly (e.g., from DailyNewsEdition.previewSession)
    func cacheSession(_ session: StudySession) {
        detailCache[session.id] = session
        detailStatusById[session.id] = .ready
    }

    // MARK: - Claim session access

    func claimSessionAccess(sessionId: String) async -> SessionAccessState? {
        do {
            let payload = try await apiClient.claimSession(sessionId: sessionId)
            progressRows[sessionId] = payload.progressState
            if let access = payload.access {
                applyAccessUpdate(sessionId: sessionId, access: access)
            }
            return payload.access
        } catch {
            #if DEBUG
            print("[LibraryService] claimSessionAccess failed for \(sessionId): \(error)")
            #endif
            return nil
        }
    }

    // MARK: - Private Helpers

    private func applyAccessUpdate(sessionId: String, access: SessionAccessState) {
        sessions = sessions.map { item in
            guard item.id == sessionId else { return item }
            return StudySessionListItem(
                id: item.id,
                overview: item.overview,
                progress: item.progress,
                createdAt: item.createdAt,
                lastStudiedAt: item.lastStudiedAt,
                updatedAt: item.updatedAt,
                summaries: item.summaries,
                access: access,
                progressState: item.progressState
            )
        }
    }
}
