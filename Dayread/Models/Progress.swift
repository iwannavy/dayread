import Foundation

struct LearningProgress: Codable {
    var totalSessions: Int
    var totalSentencesStudied: Int
    var totalExercisesCompleted: Int
    var totalQuizzesTaken: Int
    var totalWritings: Int
    var totalSpeakingMinutes: Double
    var vocabularyMastered: Int
    var patternsMastered: Int
    var streak: Int
    var lastActiveDate: String
    var dailyLog: [DailyLog]
    var weeklyGoals: WeeklyGoals

    static let empty = LearningProgress(
        totalSessions: 0,
        totalSentencesStudied: 0,
        totalExercisesCompleted: 0,
        totalQuizzesTaken: 0,
        totalWritings: 0,
        totalSpeakingMinutes: 0,
        vocabularyMastered: 0,
        patternsMastered: 0,
        streak: 0,
        lastActiveDate: "",
        dailyLog: [],
        weeklyGoals: .default
    )
}

struct DailyLog: Codable {
    let date: String
    let sessionsCompleted: Int
    let sentencesStudied: Int
    let exercisesDone: Int
    let writingWords: Int
    let speakingMinutes: Double
    let quizScore: Double?
}

struct WeeklyGoals: Codable {
    let sessionsPerWeek: Int
    let sentencesPerDay: Int
    let writingsPerWeek: Int
    let speakingMinutesPerWeek: Double

    static let `default` = WeeklyGoals(
        sessionsPerWeek: 5,
        sentencesPerDay: 10,
        writingsPerWeek: 3,
        speakingMinutesPerWeek: 30
    )
}
