import Foundation

enum SRSItemType: String, Codable {
    case vocabulary, pattern, expression, sentence
}

struct SRSItem: Codable, Identifiable {
    let id: String
    let type: SRSItemType
    let front: String
    let back: String
    let source: String
    var ease: Double
    var interval: Int
    var repetitions: Int
    var nextReview: String
    var lastReview: String?
    var archived: Bool

    init(id: String, type: SRSItemType, front: String, back: String, source: String,
         ease: Double, interval: Int, repetitions: Int, nextReview: String,
         lastReview: String?, archived: Bool) {
        self.id = id; self.type = type; self.front = front; self.back = back
        self.source = source; self.ease = ease; self.interval = interval
        self.repetitions = repetitions; self.nextReview = nextReview
        self.lastReview = lastReview; self.archived = archived
    }

    static func initial(id: String, type: SRSItemType, front: String, back: String, source: String) -> SRSItem {
        SRSItem(
            id: id, type: type, front: front, back: back, source: source,
            ease: 2.5, interval: 0, repetitions: 0,
            nextReview: ISO8601DateFormatter().string(from: Date()),
            lastReview: nil, archived: false
        )
    }

    // Backward-compatible decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(SRSItemType.self, forKey: .type)
        front = try container.decode(String.self, forKey: .front)
        back = try container.decode(String.self, forKey: .back)
        source = try container.decode(String.self, forKey: .source)
        ease = try container.decode(Double.self, forKey: .ease)
        interval = try container.decode(Int.self, forKey: .interval)
        repetitions = try container.decode(Int.self, forKey: .repetitions)
        nextReview = try container.decode(String.self, forKey: .nextReview)
        lastReview = try container.decodeIfPresent(String.self, forKey: .lastReview)
        archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
    }

    /// Current review level (0-5) based on repetitions
    var level: Int {
        min(repetitions, SRSAlgorithm.fixedIntervals.count)
    }

    /// Next interval label
    var nextIntervalLabel: String {
        if archived { return "완료" }
        if level >= SRSAlgorithm.fixedIntervals.count { return "완료" }
        let days = SRSAlgorithm.fixedIntervals[level]
        return "\(days)일"
    }
}
