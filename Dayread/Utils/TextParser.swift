import Foundation

enum TextParser {
    static func wordCount(_ text: String) -> Int {
        text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }

    static func truncate(_ text: String, maxLength: Int, suffix: String = "...") -> String {
        if text.count <= maxLength { return text }
        let endIndex = text.index(text.startIndex, offsetBy: maxLength)
        return String(text[..<endIndex]) + suffix
    }

    static func difficultyLabel(_ difficulty: Int) -> String {
        switch difficulty {
        case 1: return "Elementary"
        case 2: return "Intermediate"
        case 3: return "Upper-Intermediate"
        case 4: return "Advanced"
        case 5: return "Proficiency"
        default: return "Unknown"
        }
    }

    static func difficultyLabelKo(_ difficulty: Int) -> String {
        switch difficulty {
        case 1: return "초급"
        case 2: return "중급"
        case 3: return "중상급"
        case 4: return "고급"
        case 5: return "최상급"
        default: return "미정"
        }
    }
}
