import Foundation

/// SM-2 spaced repetition algorithm implementation
/// Port of src/lib/srs.ts
enum SRSAlgorithm {
    static let maxInterval = 30

    /// Process a review and return updated SRS item
    /// - Parameters:
    ///   - item: The SRS item being reviewed
    ///   - quality: Rating 0-5 (0=blackout, 5=perfect)
    /// - Returns: Updated SRS item with new scheduling
    static func review(_ item: SRSItem, quality: Int) -> SRSItem {
        var updated = item
        let q = Double(min(5, max(0, quality)))

        // Update ease factor
        let newEase = item.ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        updated.ease = max(1.3, newEase)

        if quality >= 3 {
            // Correct response
            switch item.repetitions {
            case 0:
                updated.interval = 1
            case 1:
                updated.interval = 3
            default:
                updated.interval = min(maxInterval, Int(Double(item.interval) * item.ease))
            }
            updated.repetitions = item.repetitions + 1
        } else {
            // Incorrect response - reset
            updated.repetitions = 0
            updated.interval = 1
        }

        let calendar = Calendar.current
        let nextDate = calendar.date(byAdding: .day, value: updated.interval, to: Date()) ?? Date()
        updated.nextReview = ISO8601DateFormatter().string(from: nextDate)
        updated.lastReview = ISO8601DateFormatter().string(from: Date())

        return updated
    }

    /// Check if an item is due for review
    static func isDue(_ item: SRSItem) -> Bool {
        guard let reviewDate = DateFormatters.parseISO(item.nextReview) else { return true }
        return Date() >= reviewDate
    }

    /// Get items due for review from a collection
    static func dueItems(from items: [SRSItem]) -> [SRSItem] {
        items.filter { isDue($0) }
    }

    /// Get review statistics
    static func stats(from items: [SRSItem]) -> ReviewStats {
        var due = 0
        var learning = 0
        var mature = 0
        var newCount = 0

        for item in items {
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

        return ReviewStats(due: due, learning: learning, mature: mature, new: newCount)
    }
}

struct ReviewStats {
    let due: Int
    let learning: Int
    let mature: Int
    let new: Int
}
