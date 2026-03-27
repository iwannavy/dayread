import Foundation

// MARK: - Response Wrappers

struct DailyNewsResponse: Codable {
    let edition: DailyNewsEdition?
}

struct DailyNewsArchiveResponse: Codable {
    let editions: [DailyNewsEditionSummary]
}

// MARK: - Endpoints

extension APIClient {
    func fetchCurrentDailyNews() async throws -> DailyNewsResponse {
        try await get("/api/daily-news/current")
    }

    func fetchDailyNews(date: String) async throws -> DailyNewsResponse {
        try await get("/api/daily-news/\(date)")
    }

    func fetchDailyNewsArchive(limit: Int = 30, offset: Int = 0) async throws -> DailyNewsArchiveResponse {
        try await get("/api/daily-news/archive?limit=\(limit)&offset=\(offset)")
    }
}
