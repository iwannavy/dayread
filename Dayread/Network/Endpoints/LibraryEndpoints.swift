import Foundation

// MARK: - Response Wrappers

struct LibrarySummaryPayload: Codable {
    let membershipTier: MembershipTier
    let sessions: [StudySessionListItem]
}

struct LibrarySessionPayload: Codable {
    let access: SessionAccessState?
    let progressState: UserSessionProgressState
    let session: StudySession?
}

struct LibraryProgressPayload: Codable {
    let access: SessionAccessState?
    let progressState: UserSessionProgressState
}

struct LibraryClaimPayload: Codable {
    let access: SessionAccessState?
    let progressState: UserSessionProgressState
}

// MARK: - Request Bodies

struct ProgressUpdateBody: Codable {
    let progressState: UserSessionProgressState
}

struct ClaimBody: Codable {
    let sessionId: String
}

// MARK: - Endpoints

extension APIClient {
    func fetchLibrarySummaries() async throws -> LibrarySummaryPayload {
        try await get("/api/library/summaries")
    }

    func fetchSessionDetail(id: String) async throws -> LibrarySessionPayload {
        try await get("/api/library/sessions/\(id)")
    }

    func saveSessionProgress(sessionId: String, progressState: UserSessionProgressState) async throws -> LibraryProgressPayload {
        try await patch("/api/library/progress/\(sessionId)", body: ProgressUpdateBody(progressState: progressState))
    }

    func claimSession(sessionId: String) async throws -> LibraryClaimPayload {
        try await post("/api/library/claim", body: ClaimBody(sessionId: sessionId))
    }
}
