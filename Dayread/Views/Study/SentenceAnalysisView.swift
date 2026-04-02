import SwiftUI

struct SentenceAnalysisView: View {
    let sentence: AnalyzedSentence
    var sessionId: String = ""
    var onPatternComplete: (() -> Void)? = nil

    @Environment(SRSService.self) private var srsService

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Vocabulary
            if !sentence.vocabulary.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("핵심 단어")

                    ForEach(Array(sentence.vocabulary.enumerated()), id: \.offset) { _, v in
                        vocabularyCard(v)
                    }
                }
            }

            // Expressions
            if !sentence.expressions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("핵심 표현")

                    ForEach(Array(sentence.expressions.enumerated()), id: \.offset) { _, ex in
                        expressionCard(ex)
                    }
                }
            }

            // Patterns with inline drill
            if !sentence.patterns.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("패턴")

                    ForEach(Array(sentence.patterns.enumerated()), id: \.offset) { _, p in
                        patternCard(p)
                    }
                }
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .studySectionHeaderStyle()
    }

    // MARK: - Vocabulary Card

    private func vocabularyCard(_ v: AnalyzedWord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Word + badges
            HStack {
                Text(v.word)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 4) {
                    Text(v.pos)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .clipShape(Capsule())
                    Text(DifficultyLevel.label(for: v.difficulty))
                        .font(.caption2)
                        .foregroundStyle(v.difficulty >= 4 ? Color.dayreadGold : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(v.difficulty >= 4 ? Color.dayreadGold.opacity(0.1) : Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                }
                Spacer()

                // Save to SRS button
                let isSaved = srsService.isSaved(front: v.word, type: .vocabulary)
                Button {
                    srsService.toggleSave(
                        type: .vocabulary,
                        front: v.word,
                        back: v.meaning,
                        source: sessionId
                    )
                    HapticsService.shared.light()
                } label: {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                        .font(.body)
                        .foregroundStyle(isSaved ? Color.dayreadGold : .secondary)
                }
                .buttonStyle(.plain)
            }

            // Meaning
            Text(v.meaning)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Example
            Text(v.example)
                .font(.caption)
                .italic()
                .foregroundStyle(.tertiary)
                .padding(.leading, 12)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.dayreadGold.opacity(0.2))
                        .frame(width: 2)
                }

            // Collocations
            if !v.collocations.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(Array(v.collocations.enumerated()), id: \.offset) { _, c in
                        Text(c)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.dayreadGold.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(StudyLayout.cardPadding)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusMD))
    }

    // MARK: - Expression Card

    private func expressionCard(_ ex: Expression) -> some View {
        let isSaved = srsService.isSaved(front: ex.phrase, type: .expression)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ex.phrase)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button {
                    srsService.toggleSave(
                        type: .expression,
                        front: ex.phrase,
                        back: ex.meaning,
                        source: sessionId
                    )
                    HapticsService.shared.light()
                } label: {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                        .font(.body)
                        .foregroundStyle(isSaved ? Color.dayreadGold : .secondary)
                }
                .buttonStyle(.plain)
            }

            Text(ex.meaning)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !ex.usage.isEmpty {
                Text(ex.usage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .padding(StudyLayout.cardPadding)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusMD))
    }

    // MARK: - Pattern Card

    private func patternCard(_ p: GrammarPattern) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Pattern header
            VStack(alignment: .leading, spacing: 4) {
                Text(p.pattern)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.dayreadGold)
                Text(p.explanation)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)

            Divider()

            // Inline drill
            PatternDrillView(
                pattern: p.pattern,
                examples: p.examples,
                drillQuestions: p.drillQuestions ?? [],
                onComplete: { onPatternComplete?() }
            )
            .padding(12)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StudyLayout.cornerRadiusMD))
    }
}
