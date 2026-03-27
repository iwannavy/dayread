import Foundation

enum QuizQuestionType: String, Codable {
    case vocabulary, grammar, comprehension, translation
}

struct QuizQuestion: Codable, Identifiable {
    let id: String
    let type: QuizQuestionType
    let question: String
    let questionKo: String?
    let options: [String]?
    let correctAnswer: String
    let explanation: String
    let points: Int
    let difficulty: Int
}

struct QuizTypeScore: Codable {
    let correct: Int
    let total: Int
}

struct QuizScore: Codable {
    let sessionId: String
    let totalPoints: Int
    let earnedPoints: Int
    let byType: [String: QuizTypeScore]
    let timestamp: String
}
