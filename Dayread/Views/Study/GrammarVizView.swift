import SwiftUI

struct GrammarVizView: View {
    let elements: [GrammarElement]
    let translation: String
    var original: String? = nil
    var koreanAlignment: [KoreanAlignment]? = nil
    var notes: String? = nil
    var rhetoricalDevice: String? = nil
    var hideOriginal = false
    var allActive = false
    var compact = false
    var onWordTap: ((String) -> Void)? = nil

    @State private var activeElement: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 16) {
            // Color-coded sentence
            if !hideOriginal {
                colorCodedSentence
            }

            // Korean translation
            Text(translation)
                .font(compact ? .studyContext : .studyTranslation)
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            // Korean-English alignment pills (non-compact)
            if !compact, let pairs = koreanAlignment, !pairs.isEmpty {
                alignmentPills(pairs)
            }

            // Structure diagram (non-compact)
            if !compact {
                structureDiagram
            }

            // Rhetorical device (non-compact)
            if !compact, let device = rhetoricalDevice, !device.isEmpty {
                rhetoricalDeviceView(device)
            }

            // Notes (non-compact)
            if !compact, let notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .italic()
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Color-Coded Sentence

    private var colorCodedSentence: some View {
        buildColorCodedText()
            .font(compact ? .studyContext : .studySentence)
            .lineSpacing(8)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func buildColorCodedText() -> Text {
        let segments = buildSegments()
        var result = Text("")
        for segment in segments {
            switch segment {
            case .plain(let text):
                result = result + Text(text)
            case .element(let element, let elementIndex):
                let isActive = allActive || activeElement == elementIndex
                let color = Color.grammarColor(for: element.role)
                let word = element.text.trimmingCharacters(in: .whitespaces)
                if isActive {
                    result = result + Text(word)
                        .foregroundColor(color)
                        .underline(color: color)
                } else {
                    result = result + Text(word)
                }
            }
        }
        return result
    }

    // MARK: - Alignment Pills

    private func alignmentPills(_ pairs: [KoreanAlignment]) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                HStack(spacing: 4) {
                    Text(pair.en)
                        .font(.caption)
                        .foregroundStyle(.primary)
                    Text("=")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(pair.ko)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.quaternary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Structure Diagram

    private var structureDiagram: some View {
        FlowLayout(spacing: 6) {
            ForEach(Array(elements.enumerated()), id: \.offset) { idx, el in
                let isActive = allActive || activeElement == idx
                HStack(spacing: 4) {
                    Text("\(el.role.label) \(el.role.labelKo)")
                        .font(.caption2)
                }
                .foregroundColor(Color.grammarColor(for: el.role))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.grammarBgColor(for: el.role))
                        .grammarHighlight(isActive: isActive, color: Color.grammarColor(for: el.role))
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("\(el.role.labelKo): \(el.text.trimmingCharacters(in: .whitespaces))")
                .accessibilityHint("탭하여 문장에서 강조 표시")
                .onTapGesture {
                    if !allActive {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            activeElement = activeElement == idx ? nil : idx
                        }
                    }
                    onWordTap?(el.text.trimmingCharacters(in: .whitespaces))
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("문법 구조 분석")
    }

    // MARK: - Rhetorical Device

    private func rhetoricalDeviceView(_ device: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("수사법")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.tertiary)
            Text(device)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dayreadGold.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Segment Building

    private enum Segment {
        case plain(String)
        case element(GrammarElement, Int)
    }

    private func buildSegments() -> [Segment] {
        guard let original, !original.isEmpty else {
            var segments: [Segment] = []
            for (i, el) in elements.enumerated() {
                segments.append(.element(el, i))
                if i < elements.count - 1 { segments.append(.plain(" ")) }
            }
            return segments
        }

        // Independent matching — handles out-of-order grammar elements
        struct Match { let range: Range<String.Index>; let idx: Int }
        var matches: [Match] = []
        var usedRanges: [Range<String.Index>] = []

        for (i, el) in elements.enumerated() {
            let trimmed = el.text.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            var searchStart = original.startIndex
            while searchStart < original.endIndex {
                guard let range = original.range(of: trimmed, range: searchStart..<original.endIndex) else { break }
                let overlaps = usedRanges.contains { $0.lowerBound < range.upperBound && $0.upperBound > range.lowerBound }
                if !overlaps {
                    matches.append(Match(range: range, idx: i))
                    usedRanges.append(range)
                    break
                }
                searchStart = range.upperBound
            }
        }

        matches.sort { $0.range.lowerBound < $1.range.lowerBound }

        var segments: [Segment] = []
        var pos = original.startIndex

        for match in matches {
            if match.range.lowerBound < pos { continue }
            if match.range.lowerBound > pos {
                segments.append(.plain(String(original[pos..<match.range.lowerBound])))
            }
            segments.append(.element(elements[match.idx], match.idx))
            pos = match.range.upperBound
        }

        // Add unmatched elements at the end
        for (i, el) in elements.enumerated() {
            if !matches.contains(where: { $0.idx == i }) {
                segments.append(.plain(" "))
                segments.append(.element(el, i))
            }
        }

        if pos < original.endIndex {
            segments.append(.plain(String(original[pos...])))
        }

        return segments
    }
}

// MARK: - Flow Layout (wrapping)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(subviews: subviews, containerWidth: proposal.width ?? .infinity)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(subviews: subviews, containerWidth: bounds.width)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private struct LayoutResult {
        var positions: [CGPoint]
        var sizes: [CGSize]
        var size: CGSize
    }

    private func layout(subviews: Subviews, containerWidth: CGFloat) -> LayoutResult {
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let ideal = subview.sizeThatFits(.unspecified)
            let size = CGSize(width: min(ideal.width, containerWidth), height: ideal.height)
            if x + size.width > containerWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            sizes.append(size)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x - spacing)
        }

        return LayoutResult(
            positions: positions,
            sizes: sizes,
            size: CGSize(width: maxWidth, height: y + rowHeight)
        )
    }
}

