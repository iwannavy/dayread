import Foundation

/// Loads bundled session JSON files from the app bundle.
/// Port of web project's `getLocalStudySession()` pattern.
@Observable
final class BundledSessionStore {

    // MARK: - Manifest

    struct ManifestEntry: Codable, Identifiable {
        let id: String
        let overview: TextOverview
        let createdAt: String
        let hasSummaries: Bool
    }

    private(set) var manifest: [ManifestEntry] = []

    // MARK: - Init

    init() {
        loadManifest()
    }

    // MARK: - Public API

    /// Load a session by ID from the app bundle (lazy, on-demand).
    func getSession(_ sessionId: String) -> StudySession? {
        guard let url = Bundle.main.url(
            forResource: sessionId,
            withExtension: "json",
            subdirectory: "SessionData"
        ) else { return nil }

        guard let data = try? Data(contentsOf: url) else { return nil }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(StudySession.self, from: data)
    }

    /// Check if a session exists in the bundle.
    func hasSession(_ sessionId: String) -> Bool {
        Bundle.main.url(
            forResource: sessionId,
            withExtension: "json",
            subdirectory: "SessionData"
        ) != nil
    }

    /// Number of bundled sessions.
    var sessionCount: Int { manifest.count }

    /// Build StudySessionListItem array from the manifest.
    /// Used as fallback when API is unavailable (guest mode, offline).
    func buildSessionListItems() -> [StudySessionListItem] {
        manifest.map { entry in
            let access = buildAccessState(for: entry.id)
            return StudySessionListItem(
                id: entry.id,
                overview: entry.overview,
                progress: nil,
                createdAt: entry.createdAt,
                lastStudiedAt: nil,
                updatedAt: nil,
                summaries: nil,
                access: access,
                progressState: nil
            )
        }
    }

    // MARK: - Private

    private func loadManifest() {
        guard let url = Bundle.main.url(
            forResource: "manifest",
            withExtension: "json",
            subdirectory: "SessionData"
        ) else { return }

        guard let data = try? Data(contentsOf: url) else { return }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        manifest = (try? decoder.decode([ManifestEntry].self, from: data)) ?? []
    }

    /// Determine access state based on curriculum/collection metadata.
    private func buildAccessState(for sessionId: String) -> SessionAccessState {
        // Check if it's a curriculum session and which week
        for (week, items) in CurriculumContent.weekContent {
            if items.contains(where: { $0.sessionId == sessionId }) {
                let isFree = week <= CurriculumContent.freeWeekLimit
                return SessionAccessState(
                    category: .curriculum,
                    canOpen: isFree,
                    hasAccessHistory: false,
                    weekNumber: week,
                    releaseDate: nil,
                    lockedReason: isFree ? nil : .premiumRequired
                )
            }
        }

        // Check if it's a collection session
        for collection in CollectionContent.collections {
            if collection.sessions.contains(where: { $0.sessionId == sessionId }) {
                let isFree = CollectionContent.isFreeCollectionSessionId(sessionId)
                return SessionAccessState(
                    category: .collection,
                    canOpen: isFree,
                    hasAccessHistory: false,
                    weekNumber: nil,
                    releaseDate: nil,
                    lockedReason: isFree ? nil : .premiumRequired
                )
            }
        }

        // Legacy/other sessions — allow access
        return SessionAccessState(
            category: .legacy,
            canOpen: true,
            hasAccessHistory: false,
            weekNumber: nil,
            releaseDate: nil,
            lockedReason: nil
        )
    }
}
