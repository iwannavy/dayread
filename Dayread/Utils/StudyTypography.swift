import SwiftUI

// MARK: - Spacing Scale

enum StudyLayout {
    static let spacingXS:  CGFloat = 4
    static let spacingSM:  CGFloat = 8
    static let spacingMD:  CGFloat = 12
    static let spacingBase: CGFloat = 16
    static let spacingLG:  CGFloat = 20
    static let spacingXL:  CGFloat = 24
    static let spacingXXL: CGFloat = 32

    static let pageHorizontal: CGFloat = 24
    static let immersiveHorizontal: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let cardPaddingLarge: CGFloat = 24

    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 16
    static let cornerRadiusLG: CGFloat = 20
}

// MARK: - Typography Modifiers

struct StudySentenceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.title3, design: .serif))
            .lineSpacing(8)
    }
}

struct StudyContextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineSpacing(4)
    }
}

struct StudyTranslationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.callout)
            .foregroundStyle(.secondary)
            .lineSpacing(4)
    }
}

struct StudySectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption2)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(.tertiary)
    }
}

// MARK: - View Extensions

extension View {
    func studySentenceStyle() -> some View {
        self.modifier(StudySentenceModifier())
    }

    func studyContextStyle() -> some View {
        self.modifier(StudyContextModifier())
    }

    func studyTranslationStyle() -> some View {
        self.modifier(StudyTranslationModifier())
    }

    func studySectionHeaderStyle() -> some View {
        self.modifier(StudySectionHeaderModifier())
    }
}

// MARK: - Legacy Font Extension (Keeping for backward compatibility where direct font is used)

extension Font {
    static var studySentence: Font { .system(.title3, design: .serif) }
    static var studyContext: Font { .subheadline }
    static var studyTranslation: Font { .callout }
    static var studyWord: Font { .subheadline }
    static var studyExample: Font { .caption }
    static var studyBadge: Font { .caption2 }
}
