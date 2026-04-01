import Foundation

/// Fixed-interval spaced repetition algorithm
/// Schedule: 1일 → 3일 → 7일 → 14일 → 30일 → archive
enum SRSAlgorithm {
    static let fixedIntervals = [1, 3, 7, 14, 30]

    /// Process a review and return updated SRS item
    /// - Parameters:
    ///   - item: The SRS item being reviewed
    ///   - quality: Rating 0-5 (0=blackout, 5=perfect). >= 3 = correct.
    /// - Returns: Updated SRS item with new scheduling
    static func review(_ item: SRSItem, quality: Int) -> SRSItem {
        var updated = item
        guard !item.archived else { return item }

        if quality >= 3 {
            // Correct — advance to next interval
            updated.repetitions = item.repetitions + 1
            if updated.repetitions >= fixedIntervals.count {
                // Completed all intervals → archive
                updated.archived = true
                updated.interval = 0
            } else {
                updated.interval = fixedIntervals[updated.repetitions - 1]
            }
        } else {
            // Incorrect — reset to first interval
            updated.repetitions = 0
            updated.interval = 1
        }

        let calendar = Calendar.current
        let nextDate = calendar.date(byAdding: .day, value: max(updated.interval, 1), to: Date()) ?? Date()
        updated.nextReview = DateFormatters.iso8601.string(from: nextDate)
        updated.lastReview = DateFormatters.iso8601.string(from: Date())

        return updated
    }

    /// Check if an item is due for review
    static func isDue(_ item: SRSItem) -> Bool {
        guard !item.archived else { return false }
        guard let reviewDate = DateFormatters.parseISO(item.nextReview) else { return true }
        return Date() >= reviewDate
    }

    /// Get items due for review from a collection
    static func dueItems(from items: [SRSItem]) -> [SRSItem] {
        items.filter { isDue($0) }
    }

    /// Get review statistics
    static func stats(from items: [SRSItem]) -> ReviewStats {
        let active = items.filter { !$0.archived }
        var due = 0
        var learning = 0
        var mature = 0
        var newCount = 0

        for item in active {
            if isDue(item) {
                due += 1
            }
            if item.repetitions == 0 {
                newCount += 1
            } else if item.interval < 7 {
                learning += 1
            } else {
                mature += 1
            }
        }

        return ReviewStats(
            due: due,
            learning: learning,
            mature: mature,
            new: newCount,
            archived: items.filter(\.archived).count
        )
    }
}

struct ReviewStats {
    let due: Int
    let learning: Int
    let mature: Int
    let new: Int
    let archived: Int

    init(due: Int, learning: Int, mature: Int, new: Int, archived: Int = 0) {
        self.due = due
        self.learning = learning
        self.mature = mature
        self.new = new
        self.archived = archived
    }

    var totalActive: Int { due + learning + mature + new - due }
}
