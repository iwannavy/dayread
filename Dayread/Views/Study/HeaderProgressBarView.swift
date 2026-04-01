import SwiftUI

// MARK: - Step Calculation Utilities

enum StudyStepUtils {
    static func computeTotalSteps(_ n: Int) -> Int {
        2 + n + 3 * n + 2 // 4n + 4
    }

    static func stageRange(_ n: Int, stage: ViewMode) -> ClosedRange<Int> {
        switch stage {
        case .overview: return 0...1
        case .immersive: return 2...(2 + n - 1)
        case .focus: return (2 + n)...(2 + n + 3 * n - 1)
        case .reoverview: return (2 + 4 * n)...(2 + 4 * n + 1)
        }
    }

    static func stageLabel(step: Int, n: Int) -> String {
        if step <= 1 { return "Intro" }
        if step < 2 + n { return "Immersive \(step - 1)/\(n)" }
        if step < 2 + n + 3 * n {
            let focusStep = step - 2 - n
            let sentIdx = focusStep / 3 + 1
            return "Focus \(sentIdx)/\(n)"
        }
        return "Final"
    }
}

// MARK: - Stage Section

private struct StageSection: Identifiable {
    let id: String
    let stepRange: Range<Int>
    let ratio: CGFloat
}

// MARK: - Header Progress Bar View

struct HeaderProgressBarView: View {
    let sentenceCount: Int
    let currentStep: Int
    let maxUnlockedStep: Int
    var onGoToStep: ((Int) -> Void)? = nil

    @State private var dragTargetStep: Int? = nil
    @State private var dragX: CGFloat = 0

    private var totalSteps: Int { StudyStepUtils.computeTotalSteps(sentenceCount) }

    private var stageBreaks: Set<Int> {
        let n = sentenceCount
        return [2, 2 + n, 2 + n + 3 * n]
    }

    // Stage sections with weighted ratios: Overview 2/10, Immersive 4/10, Focus 4/10
    private var stageSections: [StageSection] {
        let n = sentenceCount
        return [
            StageSection(id: "overview", stepRange: 0..<2, ratio: 0.2),
            StageSection(id: "immersive", stepRange: 2..<(2 + n), ratio: 0.4),
            StageSection(id: "focus", stepRange: (2 + n)..<totalSteps, ratio: 0.4),
        ]
    }

    // Gap between stages
    private let stageGap: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            let totalGaps = stageGap * CGFloat(stageSections.count - 1)
            let usableWidth = geo.size.width - totalGaps

            ZStack(alignment: .leading) {
                // Progress bar segments
                HStack(spacing: 0) {
                    ForEach(Array(stageSections.enumerated()), id: \.element.id) { sIdx, section in
                        let sectionWidth = usableWidth * section.ratio
                        let stepCount = section.stepRange.count

                        HStack(spacing: 0) {
                            ForEach(section.stepRange, id: \.self) { i in
                                stepSegment(i)
                                    .frame(width: stepCount > 0 ? sectionWidth / CGFloat(stepCount) : 0)
                            }
                        }

                        if sIdx < stageSections.count - 1 {
                            Spacer().frame(width: stageGap)
                        }
                    }
                }

                // Drag indicator label
                if let target = dragTargetStep {
                    Text(StudyStepUtils.stageLabel(step: target, n: sentenceCount))
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .position(x: clampLabelX(dragX, width: geo.size.width), y: -14)
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.15), value: target)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        dragX = value.location.x
                        let step = stepFromPosition(value.location.x, width: geo.size.width, usableWidth: usableWidth)
                        if step <= maxUnlockedStep {
                            dragTargetStep = step
                            onGoToStep?(step)
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragTargetStep = nil
                        }
                    }
            )
        }
        .frame(height: 5)
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("학습 진행률")
        .accessibilityValue("전체 \(totalSteps)단계 중 \(currentStep + 1)단계")
    }

    // MARK: - Step Segment

    private func stepSegment(_ i: Int) -> some View {
        let isLocked = i > maxUnlockedStep
        let isCurrent = i == currentStep

        return Rectangle()
            .fill(segmentColor(i, isCurrent: isCurrent))
            .frame(height: isCurrent ? 5 : 3)
            .opacity(isLocked ? 0.25 : 1)
    }

    private func segmentColor(_ i: Int, isCurrent: Bool) -> Color {
        if isCurrent {
            return Color(red: 26/255, green: 86/255, blue: 140/255) // #1a568c
        }
        if i <= maxUnlockedStep && i < currentStep {
            return Color.statusShadowed // #2a8a87
        }
        return Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.08)
    }

    // MARK: - Position Mapping (weighted by stage ratios)

    private func stepFromPosition(_ x: CGFloat, width: CGFloat, usableWidth: CGFloat) -> Int {
        guard totalSteps > 0, width > 0 else { return 0 }
        let clampedX = max(0, min(width, x))

        // Determine which stage section the x position falls in
        var accumulatedX: CGFloat = 0
        for (sIdx, section) in stageSections.enumerated() {
            let sectionWidth = usableWidth * section.ratio
            let sectionEnd = accumulatedX + sectionWidth

            if clampedX < sectionEnd || sIdx == stageSections.count - 1 {
                // Within this section
                let localX = clampedX - accumulatedX
                let stepCount = section.stepRange.count
                guard stepCount > 0 else { return section.stepRange.lowerBound }
                let ratio = max(0, min(1, localX / sectionWidth))
                let localStep = Int(round(ratio * CGFloat(stepCount - 1)))
                return section.stepRange.lowerBound + localStep
            }

            accumulatedX = sectionEnd + stageGap
        }
        return totalSteps - 1
    }

    private func clampLabelX(_ x: CGFloat, width: CGFloat) -> CGFloat {
        max(40, min(width - 40, x))
    }
}
