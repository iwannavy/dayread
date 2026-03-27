import Foundation

enum ExerciseType: String, Codable {
    case fillBlank = "fill-blank"
    case reconstruction
    case translation
    case patternApply = "pattern-apply"
    case errorCorrection = "error-correction"
    case synonymMatch = "synonym-match"
    case collocation
}

struct Exercise: Codable, Identifiable {
    let id: String
    let type: ExerciseType
    let sentenceId: Int
    let question: String
    let questionKo: String?
    let options: [String]?
    let correctAnswer: String
    let hint: String?
    let explanation: String
    let difficulty: Int
}

struct ExerciseResult: Codable {
    let exerciseId: String
    let type: ExerciseType
    let userAnswer: String
    let correct: Bool
    let timestamp: String
}

struct ExerciseSet: Codable {
    let sessionId: String
    let exercises: [Exercise]
    let sentenceIds: [Int]
}
