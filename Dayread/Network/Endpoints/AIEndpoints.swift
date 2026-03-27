import Foundation

extension APIClient {
    func generateExercises(sessionId: String, sentenceIds: [Int], sentences: [AnalyzedSentence]) async throws -> ExerciseSet {
        try await post("/api/exercise", body: ExerciseRequest(
            sessionId: sessionId,
            sentenceIds: sentenceIds,
            sentences: sentences
        ))
    }

    func generateQuiz(sessionId: String, sentences: [AnalyzedSentence]) async throws -> [QuizQuestion] {
        try await post("/api/quiz", body: QuizRequest(
            sessionId: sessionId,
            sentences: sentences
        ))
    }

    func getWritingCoachFeedback(content: String, sessionId: String?, context: WritingCoachContext?) async throws -> WritingCoachResponse {
        try await post("/api/writing-coach", body: WritingCoachRequest(
            content: content,
            sessionId: sessionId,
            context: context
        ))
    }

    func generatePatternDrill(pattern: String, explanation: String, examples: [String]) async throws -> [PatternDrillQuestion] {
        try await post("/api/pattern-drill", body: PatternDrillRequest(
            pattern: pattern,
            explanation: explanation,
            examples: examples
        ))
    }

    func generateDailyDrill(sentences: [AnalyzedSentence], vocabulary: [AnalyzedWord], patterns: [GrammarPattern]) async throws -> DailyDrillResponse {
        try await post("/api/drill", body: DailyDrillRequest(
            sentences: sentences,
            vocabulary: vocabulary,
            patterns: patterns
        ))
    }
}

// MARK: - Request/Response Types

struct ExerciseRequest: Encodable {
    let sessionId: String
    let sentenceIds: [Int]
    let sentences: [AnalyzedSentence]
}

struct QuizRequest: Encodable {
    let sessionId: String
    let sentences: [AnalyzedSentence]
}

struct WritingCoachContext: Codable {
    let patterns: [String]?
    let vocabulary: [String]?
}

struct WritingCoachRequest: Encodable {
    let content: String
    let sessionId: String?
    let context: WritingCoachContext?
}

struct WritingCoachResponse: Codable {
    let corrections: [WritingCorrection]
    let feedback: String
    let score: Double?
}

struct PatternDrillRequest: Encodable {
    let pattern: String
    let explanation: String
    let examples: [String]
}

struct DailyDrillRequest: Encodable {
    let sentences: [AnalyzedSentence]
    let vocabulary: [AnalyzedWord]
    let patterns: [GrammarPattern]
}

struct DailyDrillResponse: Codable {
    let reviewSentences: [AnalyzedSentence]?
    let writingPrompt: String?
    let speakingChallenge: SpeakingChallenge?
}
