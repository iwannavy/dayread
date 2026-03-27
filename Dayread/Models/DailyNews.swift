import Foundation

enum DailyNewsEditionStatus: String, Codable {
    case draft, approved, sent
}

struct DailyNewsSource: Codable, Identifiable {
    let id: String
    let editionDate: String
    let publisher: String
    let url: String
    let headline: String
    let factBullets: [String]
    let riskFlags: [String]
    let enteredBy: String?
    let enteredAt: String
}

struct DailyNewsEditionSummary: Codable {
    let editionDate: String
    let sessionId: String?
    let status: DailyNewsEditionStatus
    let subjectLine: String
    let introKo: String
    let introEn: String
    let riskFlags: [String]
    let approvedAt: String?
    let sentAt: String?
    let isToday: Bool
}

struct DailyNewsEdition: Codable {
    let editionDate: String
    let sessionId: String?
    let status: DailyNewsEditionStatus
    let subjectLine: String
    let introKo: String
    let introEn: String
    let riskFlags: [String]
    let approvedAt: String?
    let sentAt: String?
    let isToday: Bool
    let sources: [DailyNewsSource]
    let previewSession: StudySession?
}
