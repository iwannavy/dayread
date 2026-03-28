import SwiftUI

struct SessionListItemView: View {
    let session: StudySessionListItem
    let membershipTier: MembershipTier
    let onTap: () -> Void
    var onAppear: (() -> Void)?

    private var isLocked: Bool {
        !(session.access?.canOpen ?? false)
    }

    private var progressPercent: Double {
        guard let progress = session.progress else { return 0 }
        let total = session.overview.sentenceCount
        guard total > 0 else { return 0 }
        return Double(progress.studiedSentences.count) / Double(total) * 100
    }

    private var isCompleted: Bool {
        progressPercent >= 100
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Genre icon
                Image(systemName: CurriculumUtils.genreIcon("article"))
                    .font(.system(size: 16))
                    .foregroundStyle(isLocked ? .secondary : CurriculumUtils.difficultyColor(session.overview.difficulty))
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill((isLocked ? Color.gray : CurriculumUtils.difficultyColor(session.overview.difficulty)).opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(session.overview.title)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isLocked ? .secondary : .primary)
                            .lineLimit(1)

                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.dayreadGold)
                        }

                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }

                    HStack(spacing: 8) {
                        Text(session.overview.source)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if !isLocked && progressPercent > 0 && !isCompleted {
                            ProgressView(value: progressPercent, total: 100)
                                .tint(Color.dayreadGold)
                                .frame(width: 40)

                            Text("\(Int(progressPercent))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(CurriculumUtils.difficultyLabel(session.overview.difficulty))
                            .font(.caption2)
                            .foregroundStyle(CurriculumUtils.difficultyColor(session.overview.difficulty))
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isLocked ? Color(.systemGray6).opacity(0.5) : Color(.systemBackground))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(sessionAccessibilityLabel)
        .accessibilityHint(isLocked ? "프리미엄 구독으로 잠금 해제" : "탭하여 학습 시작")
        .onAppear { onAppear?() }
    }

    private var sessionAccessibilityLabel: String {
        var parts = [session.overview.title]
        if isLocked {
            parts.insert("프리미엄 전용 세션:", at: 0)
        }
        parts.append("난이도 \(session.overview.difficulty)")
        if isCompleted {
            parts.append("완료됨")
        } else if progressPercent > 0 {
            parts.append("진행률 \(Int(progressPercent))%")
        }
        return parts.joined(separator: ", ")
    }
}
