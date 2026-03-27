import Foundation

enum SRSItemType: String, Codable {
    case vocabulary, pattern, expression
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

    static func initial(id: String, type: SRSItemType, front: String, back: String, source: String) -> SRSItem {
        SRSItem(
            id: id,
            type: type,
            front: front,
            back: back,
            source: source,
            ease: 2.5,
            interval: 0,
            repetitions: 0,
            nextReview: ISO8601DateFormatter().string(from: Date()),
            lastReview: nil
        )
    }
}
