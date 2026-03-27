import Foundation

// MARK: - Text Analysis

struct AnalyzedWord: Codable, Identifiable {
    var id: String { word }
    let word: String
    let pos: String
    let meaning: String
    let example: String
    let collocations: [String]
    let difficulty: Int
}

enum GrammarRole: String, Codable {
    case subject, verb, object, complement, modifier, conjunction, preposition, clause
}

struct GrammarElement: Codable, Identifiable {
    var id: String { "\(role.rawValue)-\(text)" }
    let text: String
    let role: GrammarRole
    let label: String
}

enum ExpressionRegister: String, Codable {
    case formal, informal, journalistic, academic, literary, neutral, technical, conversational
}

struct Expression: Codable, Identifiable {
    var id: String { phrase }
    let phrase: String
    let meaning: String
    let usage: String
    let register: ExpressionRegister
}

struct PatternDrillQuestion: Codable, Identifiable {
    var id: String { question }
    let question: String
    let answer: String
    let options: [String]?
}

struct GrammarPattern: Codable, Identifiable {
    var id: String { pattern }
    let pattern: String
    let explanation: String
    let examples: [String]
    let drillQuestions: [PatternDrillQuestion]?
}

struct KoreanAlignment: Codable {
    let en: String
    let ko: String
}

struct AnalyzedSentence: Codable, Identifiable {
    let id: Int
    let original: String
    let translation: String
    let grammarElements: [GrammarElement]
    let vocabulary: [AnalyzedWord]
    let expressions: [Expression]
    let patterns: [GrammarPattern]
    let difficulty: Int
    let notes: String
    let paragraphIndex: Int
    let koreanAlignment: [KoreanAlignment]?
    let pronunciationNotes: [String]?
    let rhetoricalDevice: String?
}

// MARK: - Overview

enum EstimatedLevel: String, Codable {
    case beginner, intermediate
    case upperIntermediate = "upper-intermediate"
    case advanced, proficiency, mastery
}

struct TextOverview: Codable {
    let title: String
    let source: String
    let wordCount: Int
    let sentenceCount: Int
    let estimatedLevel: EstimatedLevel
    let readingTimeMinutes: Int
    let mainTopics: [String]
    let keyVocabularyPreview: [String]
    let difficulty: Int
}

// MARK: - Rich Content Blocks

enum ReadableContentBlock: Codable {
    case table(TableBlock)
    case code(CodeBlock)
    case mermaid(MermaidBlock)

    struct TableBlock: Codable {
        let type: String
        let headers: [String]
        let rows: [[String]]
        let caption: String?
        let stickyFirstCol: Bool?
    }

    struct CodeBlock: Codable {
        let type: String
        let language: String
        let code: String
        let caption: String?
    }

    struct MermaidBlock: Codable {
        let type: String
        let definition: String
        let caption: String?
    }

    enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "table":
            self = .table(try TableBlock(from: decoder))
        case "code":
            self = .code(try CodeBlock(from: decoder))
        case "mermaid":
            self = .mermaid(try MermaidBlock(from: decoder))
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unknown block type: \(type)")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .table(let block): try block.encode(to: encoder)
        case .code(let block): try block.encode(to: encoder)
        case .mermaid(let block): try block.encode(to: encoder)
        }
    }
}

// MARK: - Session Summary

struct SummarySentence: Codable, Identifiable {
    let id: Int
    let text: String
    let translation: String
    let keyWords: [String]
}

struct SessionSummary: Codable {
    let level: Int
    let label: String
    let labelKo: String
    let sentences: [SummarySentence]
}

// MARK: - Session Progress

enum StudyPhaseType: String, Codable {
    case study, practice, test, writing, speaking
}

struct SessionProgress: Codable {
    let studiedSentences: [Int]
    let completedExercises: [ExerciseResult]
    let quizScores: [QuizScore]
    let writingEntries: [String]
    let speakingMinutes: Double
    let phase: StudyPhaseType
}

// MARK: - Study Session

struct StudySession: Codable, Identifiable {
    let id: String
    let rawText: String
    let overview: TextOverview
    let sentences: [AnalyzedSentence]
    let createdAt: String
    let lastStudiedAt: String?
    let progress: SessionProgress?
    let summaries: [SessionSummary]?
    let richContent: [ReadableContentBlock]?
}

// MARK: - Sentence Learning State

enum SentenceLearningStatus: String, Codable {
    case new, analyzed, listened, shadowed, practiced, mastered
}

struct SentenceLearningState: Codable {
    var status: SentenceLearningStatus
    var timesReviewed: Int
    var shadowingAttempts: Int
    var exercisesCompleted: Int
    var writingApplications: Int
    var pronunciationScore: Double?

    static let initial = SentenceLearningState(
        status: .new,
        timesReviewed: 0,
        shadowingAttempts: 0,
        exercisesCompleted: 0,
        writingApplications: 0,
        pronunciationScore: nil
    )
}

// MARK: - User Session Progress State

struct UserSessionProgressState: Codable {
    var studiedSentenceIds: [Int]
    var completedExercises: [ExerciseResult]
    var quizScores: [QuizScore]
    var writingEntries: [String]
    var speakingMinutes: Double
    var phase: StudyPhaseType
    var lastStudiedAt: String?
    var firstAccessedAt: String?
    var lastIndex: Int
    var sentenceStates: [String: SentenceLearningState]

    static let empty = UserSessionProgressState(
        studiedSentenceIds: [],
        completedExercises: [],
        quizScores: [],
        writingEntries: [],
        speakingMinutes: 0,
        phase: .study,
        lastStudiedAt: nil,
        firstAccessedAt: nil,
        lastIndex: 0,
        sentenceStates: [:]
    )
}

// MARK: - Session Access

enum SessionCategory: String, Codable {
    case curriculum, premium, legacy, collection
}

enum SessionLockedReason: String, Codable {
    case premiumRequired = "premium_required"
    case premiumWindowClosed = "premium_window_closed"
    case legacyBonusDisabled = "legacy_bonus_disabled"
}

struct SessionAccessState: Codable {
    let category: SessionCategory
    let canOpen: Bool
    let hasAccessHistory: Bool
    let weekNumber: Int?
    let releaseDate: String?
    let lockedReason: SessionLockedReason?
}

// MARK: - Study Session List Item

struct StudySessionListItem: Codable, Identifiable {
    let id: String
    let overview: TextOverview
    let progress: SessionProgress?
    let createdAt: String
    let lastStudiedAt: String?
    let updatedAt: String?
    let summaries: [SessionSummary]?
    let access: SessionAccessState?
    let progressState: UserSessionProgressState?
}
