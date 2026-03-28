import SwiftUI

// MARK: - Spacing Scale

enum StudyLayout {
    // Spacing scale: 4 / 8 / 12 / 16 / 20 / 24 / 32
    static let spacingXS:  CGFloat = 4
    static let spacingSM:  CGFloat = 8
    static let spacingMD:  CGFloat = 12
    static let spacingBase: CGFloat = 16
    static let spacingLG:  CGFloat = 20
    static let spacingXL:  CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // Horizontal page margins (consistent across all study views)
    static let pageHorizontal: CGFloat = 24

    // Immersive card — tighter margins for card-based paging
    static let immersiveHorizontal: CGFloat = 16

    // Card internal padding
    static let cardPadding: CGFloat = 16
    static let cardPaddingLarge: CGFloat = 24

    // Corner radii
    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 16
    static let cornerRadiusLG: CGFloat = 20
}

// MARK: - Typography

extension Font {
    /// Primary English sentences — serif (New York) for reading comfort
    static var studySentence: Font {
        .system(.title3, design: .serif)
    }

    /// Previous context sentences
    static var studyContext: Font {
        .subheadline
    }

    /// Korean translation text
    static var studyTranslation: Font {
        .callout
    }

    /// Vocabulary/expression word (pair with .fontWeight(.medium))
    static var studyWord: Font {
        .subheadline
    }

    /// Example sentences, notes
    static var studyExample: Font {
        .caption
    }

    /// Pill/badge label text
    static var studyBadge: Font {
        .caption2
    }
}

// MARK: - Composite Style Extensions

extension View {
    /// English primary sentence: serif title3, lineSpacing 8
    func studySentenceStyle() -> some View {
        self
            .font(.studySentence)
            .lineSpacing(8)
    }

    /// Previous context sentence: subheadline, secondary, lineSpacing 4
    func studyContextStyle() -> some View {
        self
            .font(.studyContext)
            .foregroundStyle(.secondary)
            .lineSpacing(4)
    }

    /// Korean translation: callout, secondary, lineSpacing 4
    func studyTranslationStyle() -> some View {
        self
            .font(.studyTranslation)
            .foregroundStyle(.secondary)
            .lineSpacing(4)
    }

    /// Section header: caption2, uppercase, tracking(1), tertiary
    func studySectionHeaderStyle() -> some View {
        self
            .font(.studyBadge)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(.tertiary)
    }
}
