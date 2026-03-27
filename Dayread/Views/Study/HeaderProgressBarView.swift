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

// MARK: - Header Progress Bar View

struct HeaderProgressBarView: View {
    let sentenceCount: Int
    let currentStep: Int
    let maxUnlockedStep: Int
    var onGoToStep: ((Int) -> Void)? = nil

    private var totalSteps: Int { StudyStepUtils.computeTotalSteps(sentenceCount) }

    private var stageBreaks: Set<Int> {
        let n = sentenceCount
        return [2, 2 + n, 2 + n + 3 * n]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background segments
                HStack(spacing: 0) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        stepSegment(i)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let step = stepFromPosition(value.location.x, width: geo.size.width)
                        if step <= maxUnlockedStep {
                            onGoToStep?(step)
                        }
                    }
            )
        }
        .frame(height: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("학습 진행률")
        .accessibilityValue("전체 \(totalSteps)단계 중 \(currentStep + 1)단계")
    }

    // MARK: - Step Segment

    private func stepSegment(_ i: Int) -> some View {
        let isLocked = i > maxUnlockedStep
        let isCurrent = i == currentStep
        let isBreak = stageBreaks.contains(i)

        return Rectangle()
            .fill(segmentColor(i, isCurrent: isCurrent))
            .frame(height: isCurrent ? 5 : 3)
            .opacity(isLocked ? 0.25 : 1)
            .padding(.trailing, isBreak ? 2 : 0)
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

    private func stepFromPosition(_ x: CGFloat, width: CGFloat) -> Int {
        guard totalSteps > 0, width > 0 else { return 0 }
        let ratio = max(0, min(1, x / width))
        return Int(round(ratio * Double(totalSteps - 1)))
    }
}
