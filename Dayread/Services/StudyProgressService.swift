import Foundation
import Observation

private let storageKey = "dayread-learning-progress"

@Observable
final class StudyProgressService {
    private(set) var progress: LearningProgress

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(LearningProgress.self, from: data) {
            self.progress = saved
        } else {
            self.progress = .empty
        }
    }

    // MARK: - Recording Methods

    func recordStudy(sentenceCount: Int) {
        let (log, index) = getOrCreateTodayLog()
        let updated = DailyLog(
            date: log.date,
            sessionsCompleted: log.sessionsCompleted,
            sentencesStudied: log.sentencesStudied + sentenceCount,
            exercisesDone: log.exercisesDone,
            writingWords: log.writingWords,
            speakingMinutes: log.speakingMinutes,
            quizScore: log.quizScore
        )
        let streak = computeStreak()
        progress.totalSentencesStudied += sentenceCount
        progress.dailyLog = updateDailyLogEntry(updated, at: index)
        progress.streak = streak.streak
        progress.lastActiveDate = streak.lastActiveDate
        persist()
    }

    func recordSession() {
        let (log, index) = getOrCreateTodayLog()
        let updated = DailyLog(
            date: log.date,
            sessionsCompleted: log.sessionsCompleted + 1,
            sentencesStudied: log.sentencesStudied,
            exercisesDone: log.exercisesDone,
            writingWords: log.writingWords,
            speakingMinutes: log.speakingMinutes,
            quizScore: log.quizScore
        )
        let streak = computeStreak()
        progress.totalSessions += 1
        progress.dailyLog = updateDailyLogEntry(updated, at: index)
        progress.streak = streak.streak
        progress.lastActiveDate = streak.lastActiveDate
        persist()
    }

    func recordExercise(count: Int) {
        let (log, index) = getOrCreateTodayLog()
        let updated = DailyLog(
            date: log.date,
            sessionsCompleted: log.sessionsCompleted,
            sentencesStudied: log.sentencesStudied,
            exercisesDone: log.exercisesDone + count,
            writingWords: log.writingWords,
            speakingMinutes: log.speakingMinutes,
            quizScore: log.quizScore
        )
        let streak = computeStreak()
        progress.totalExercisesCompleted += count
        progress.dailyLog = updateDailyLogEntry(updated, at: index)
        progress.streak = streak.streak
        progress.lastActiveDate = streak.lastActiveDate
        persist()
    }

    func recordQuiz(score: Double) {
        let (log, index) = getOrCreateTodayLog()
        let updated = DailyLog(
            date: log.date,
            sessionsCompleted: log.sessionsCompleted,
            sentencesStudied: log.sentencesStudied,
            exercisesDone: log.exercisesDone,
            writingWords: log.writingWords,
            speakingMinutes: log.speakingMinutes,
            quizScore: score
        )
        let streak = computeStreak()
        progress.totalQuizzesTaken += 1
        progress.dailyLog = updateDailyLogEntry(updated, at: index)
        progress.streak = streak.streak
        progress.lastActiveDate = streak.lastActiveDate
        persist()
    }

    func recordWriting(wordCount: Int) {
        let (log, index) = getOrCreateTodayLog()
        let updated = DailyLog(
            date: log.date,
            sessionsCompleted: log.sessionsCompleted,
            sentencesStudied: log.sentencesStudied,
            exercisesDone: log.exercisesDone,
            writingWords: log.writingWords + wordCount,
            speakingMinutes: log.speakingMinutes,
            quizScore: log.quizScore
        )
        let streak = computeStreak()
        progress.totalWritings += 1
        progress.dailyLog = updateDailyLogEntry(updated, at: index)
        progress.streak = streak.streak
        progress.lastActiveDate = streak.lastActiveDate
        persist()
    }

    func updateStreak() {
        let streak = computeStreak()
        progress.streak = streak.streak
        progress.lastActiveDate = streak.lastActiveDate
        persist()
    }

    // MARK: - Private Helpers

    private func getOrCreateTodayLog() -> (log: DailyLog, index: Int) {
        let today = todayString()
        if let index = progress.dailyLog.firstIndex(where: { $0.date == today }) {
            return (progress.dailyLog[index], index)
        }
        return (DailyLog(date: today, sessionsCompleted: 0, sentencesStudied: 0,
                         exercisesDone: 0, writingWords: 0, speakingMinutes: 0, quizScore: nil), -1)
    }

    private func updateDailyLogEntry(_ log: DailyLog, at index: Int) -> [DailyLog] {
        var logs = progress.dailyLog
        if index >= 0 {
            logs[index] = log
        } else {
            logs.append(log)
        }
        return logs
    }

    private func computeStreak() -> (streak: Int, lastActiveDate: String) {
        let today = todayString()
        let yesterday = yesterdayString()

        if progress.lastActiveDate == today {
            return (progress.streak, today)
        }
        if progress.lastActiveDate == yesterday {
            return (progress.streak + 1, today)
        }
        return (1, today)
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: Date())
    }

    private func yesterdayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
