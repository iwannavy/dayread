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
            HStack(spacing: 16) {
                // Progress Ring or Genre Icon
                ZStack {
                    if !isLocked && progressPercent > 0 {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 3)
                            .frame(width: 44, height: 44)
                        
                        Circle()
                            .trim(from: 0, to: progressPercent / 100)
                            .stroke(isCompleted ? Color.green : Color.dayreadGold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))
                    } else {
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 44, height: 44)
                    }

                    Image(systemName: isLocked ? "lock.fill" : (isCompleted ? "checkmark" : CurriculumUtils.genreIcon("article")))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isLocked ? Color.dayreadGold : (isCompleted ? .green : .secondary))
                }
                .padding(.leading, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text(session.overview.title)
                        .font(.system(.subheadline, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundStyle(isLocked ? .secondary : .primary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(session.overview.source)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        
                        Spacer()
                        
                        difficultyBadge
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground).opacity(0.3))
                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isCompleted ? Color.green.opacity(0.1) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .onAppear { onAppear?() }
    }

    private var difficultyBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(CurriculumUtils.difficultyColor(session.overview.difficulty))
                .frame(width: 6, height: 6)
            
            Text(CurriculumUtils.difficultyLabel(session.overview.difficulty))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemBackground).opacity(0.6))
        .clipShape(Capsule())
    }
}
