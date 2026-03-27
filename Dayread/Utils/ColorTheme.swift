import SwiftUI
import UIKit

extension Color {
    // Brand colors
    static let dayreadGold = Color(red: 168/255, green: 149/255, blue: 128/255)
    static let dayreadBrown = Color(red: 140/255, green: 120/255, blue: 95/255)
    static let dayreadCream = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? .systemBackground
            : UIColor(red: 250/255, green: 249/255, blue: 247/255, alpha: 1)
    })
    static let dayreadWarm = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? .secondarySystemBackground
            : UIColor(red: 245/255, green: 240/255, blue: 235/255, alpha: 1)
    })

    // Grammar element colors — muted/desaturated for modern readability
    static let grammarSubject = Color(red: 196/255, green: 112/255, blue: 101/255)      // muted terracotta
    static let grammarVerb = Color(red: 90/255, green: 141/255, blue: 181/255)          // muted steel blue
    static let grammarObject = Color(red: 160/255, green: 109/255, blue: 184/255)       // muted lavender
    static let grammarComplement = Color(red: 92/255, green: 184/255, blue: 130/255)    // muted sage
    static let grammarModifier = Color(red: 212/255, green: 128/255, blue: 74/255)      // muted amber
    static let grammarConjunction = Color(red: 232/255, green: 185/255, blue: 90/255)   // muted gold
    static let grammarPreposition = Color(red: 90/255, green: 112/255, blue: 133/255)   // muted slate
    static let grammarClause = Color(red: 79/255, green: 184/255, blue: 160/255)        // muted teal

    // Grammar background colors (0.08 opacity for subtlety)
    static let grammarSubjectBg = Color(red: 196/255, green: 112/255, blue: 101/255).opacity(0.08)
    static let grammarVerbBg = Color(red: 90/255, green: 141/255, blue: 181/255).opacity(0.08)
    static let grammarObjectBg = Color(red: 160/255, green: 109/255, blue: 184/255).opacity(0.08)
    static let grammarComplementBg = Color(red: 92/255, green: 184/255, blue: 130/255).opacity(0.08)
    static let grammarModifierBg = Color(red: 212/255, green: 128/255, blue: 74/255).opacity(0.08)
    static let grammarConjunctionBg = Color(red: 232/255, green: 185/255, blue: 90/255).opacity(0.08)
    static let grammarPrepositionBg = Color(red: 90/255, green: 112/255, blue: 133/255).opacity(0.08)
    static let grammarClauseBg = Color(red: 79/255, green: 184/255, blue: 160/255).opacity(0.08)

    // Sentence learning status colors — synced with grammar-colors.ts statusColors
    static let statusNew = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.08)
    static let statusAnalyzed = Color(red: 176/255, green: 120/255, blue: 56/255)   // #b07838
    static let statusListened = Color(red: 56/255, green: 120/255, blue: 160/255)    // #3878a0
    static let statusShadowed = Color(red: 42/255, green: 138/255, blue: 135/255)    // #2a8a87
    static let statusPracticed = Color(red: 45/255, green: 122/255, blue: 47/255)    // #2d7a2f
    static let statusMastered = Color(red: 154/255, green: 133/255, blue: 96/255)    // #9a8560

    // Difficulty colors — synced with grammar-colors.ts difficultyColors
    static let difficultyEasy = Color(red: 44/255, green: 62/255, blue: 80/255)       // #2c3e50
    static let difficultyMedium = Color(red: 39/255, green: 174/255, blue: 96/255)    // #27ae60
    static let difficultyHard = Color(red: 243/255, green: 156/255, blue: 18/255)     // #f39c12
    static let difficultyAdvanced = Color(red: 211/255, green: 84/255, blue: 0/255)   // #d35400
    static let difficultyExpert = Color(red: 192/255, green: 57/255, blue: 43/255)    // #c0392b
    static let difficultyMastery = Color(red: 142/255, green: 68/255, blue: 173/255)  // #8e44ad

    static func grammarColor(for role: GrammarRole) -> Color {
        switch role {
        case .subject: return .grammarSubject
        case .verb: return .grammarVerb
        case .object: return .grammarObject
        case .complement: return .grammarComplement
        case .modifier: return .grammarModifier
        case .conjunction: return .grammarConjunction
        case .preposition: return .grammarPreposition
        case .clause: return .grammarClause
        }
    }

    static func grammarBgColor(for role: GrammarRole) -> Color {
        switch role {
        case .subject: return Color(red: 196/255, green: 112/255, blue: 101/255).opacity(0.08)
        case .verb: return Color(red: 90/255, green: 141/255, blue: 181/255).opacity(0.08)
        case .object: return Color(red: 160/255, green: 109/255, blue: 184/255).opacity(0.08)
        case .complement: return Color(red: 92/255, green: 184/255, blue: 130/255).opacity(0.08)
        case .modifier: return Color(red: 212/255, green: 128/255, blue: 74/255).opacity(0.08)
        case .conjunction: return Color(red: 232/255, green: 185/255, blue: 90/255).opacity(0.08)
        case .preposition: return Color(red: 90/255, green: 112/255, blue: 133/255).opacity(0.08)
        case .clause: return Color(red: 79/255, green: 184/255, blue: 160/255).opacity(0.08)
        }
    }

    static func statusColor(for status: String) -> Color {
        switch status {
        case "analyzed": return .statusAnalyzed
        case "listened": return .statusListened
        case "shadowed": return .statusShadowed
        case "practiced": return .statusPracticed
        case "mastered": return .statusMastered
        default: return .statusNew
        }
    }

    static func difficultyColor(for difficulty: Int) -> Color {
        switch difficulty {
        case 1: return .difficultyEasy
        case 2: return .difficultyMedium
        case 3: return .difficultyHard
        case 4: return .difficultyAdvanced
        case 5: return .difficultyExpert
        case 6: return .difficultyMastery
        default: return .secondary
        }
    }
}

// MARK: - Grammar Role Labels

extension GrammarRole {
    var label: String {
        switch self {
        case .subject: return "S"
        case .verb: return "V"
        case .object: return "O"
        case .complement: return "C"
        case .modifier: return "M"
        case .conjunction: return "Conj"
        case .preposition: return "Prep"
        case .clause: return "Cl"
        }
    }

    var labelKo: String {
        switch self {
        case .subject: return "주어"
        case .verb: return "동사"
        case .object: return "목적어"
        case .complement: return "보어"
        case .modifier: return "수식어"
        case .conjunction: return "접속사"
        case .preposition: return "전치사"
        case .clause: return "절"
        }
    }
}

// MARK: - Difficulty Labels

enum DifficultyLevel {
    static let labels = ["", "Elementary", "Intermediate", "Upper-Int", "Advanced", "Proficiency", "Mastery"]

    static func label(for level: Int) -> String {
        guard level > 0, level < labels.count else { return "" }
        return labels[level]
    }
}
