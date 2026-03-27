import Foundation

struct Comment: Codable, Identifiable {
    let id: String
    let sessionId: String
    let userName: String
    let text: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case userName = "user_name"
        case text
        case createdAt = "created_at"
    }
}

enum FriendshipStatus: String, Codable {
    case pending, accepted, rejected
}

struct Friendship: Codable, Identifiable {
    let id: String
    let requesterId: String
    let addresseeId: String
    let status: FriendshipStatus
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case requesterId = "requester_id"
        case addresseeId = "addressee_id"
        case status
        case createdAt = "created_at"
    }
}

// MARK: - Writing

enum WritingPromptType: String, Codable {
    case response, summary
    case styleImitation = "style-imitation"
    case patternPractice = "pattern-practice"
    case free
}

struct WritingPrompt: Codable, Identifiable {
    let id: String
    let sessionId: String
    let type: WritingPromptType
    let prompt: String
    let promptKo: String
    let suggestedPatterns: [String]
    let suggestedVocabulary: [String]
}

enum WritingCorrectionCategory: String, Codable {
    case grammar, vocabulary, style, expression, structure
}

struct WritingCorrection: Codable {
    let original: String
    let corrected: String
    let explanation: String
    let category: WritingCorrectionCategory
}

struct WritingEntry: Codable, Identifiable {
    let id: String
    let sessionId: String
    let promptId: String?
    let content: String
    let corrections: [WritingCorrection]
    let feedback: String
    let wordCount: Int
    let patternsUsed: [String]
    let vocabularyUsed: [String]
    let score: Double?
    let createdAt: String
}

// MARK: - Speaking

enum SpeakingChallengeType: String, Codable {
    case shadowing
    case readAloud = "read-aloud"
    case summarize, discuss
}

struct SpeakingChallenge: Codable {
    let type: SpeakingChallengeType
    let targetSentences: [String]
    let promptKo: String
    let duration: Int
}

// MARK: - Daily Drill

struct DailyDrill: Codable, Identifiable {
    let id: String
    let date: String
    var completedParts: [String]
    let reviewItems: [SRSItem]?
    let sentenceIds: [Int]?
    let writingPrompt: String?
    let speakingChallenge: SpeakingChallenge?
    let completedAt: String?
}

// MARK: - Curriculum

struct CurriculumWeek: Codable {
    let week: Int
    let theme: String
    let themeKo: String
    let focus: [String]
    let targetSources: [String]
    let goals: [String]
    let difficulty: Int
    let availability: String
}

struct CurriculumMonth: Codable {
    let month: Int
    let title: String
    let titleKo: String
    let description: String
    let weeks: [CurriculumWeek]
    let milestones: [String]
}

struct CurriculumContentItem: Codable, Identifiable {
    let id: String
    let weekNumber: Int
    let title: String
    let source: String
    let genre: String
    let difficulty: Int
    let learningPoints: String
    let status: String
    let sessionId: String?
    let textFilePath: String?
    var tags: [String]? = nil
}

struct CollectionMeta: Codable, Identifiable {
    let id: String
    let title: String
    let titleKo: String
    let description: String
    let difficulty: Int
    let icon: String
    let sessions: [CollectionContentItem]
}

struct CollectionContentItem: Codable, Identifiable {
    let id: String
    let title: String
    let source: String
    let genre: String
    let difficulty: Int
    let learningPoints: String
    let status: String
    let sessionId: String?
    let textFilePath: String?
}
