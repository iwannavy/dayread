import SwiftUI

struct DailyEditionCard: View {
    let edition: DailyNewsEdition?
    var isLoading = false
    var onTap: ((String) -> Void)?

    var body: some View {
        if isLoading {
            LibrarySkeletonView()
        } else if let edition {
            Button {
                if let sessionId = edition.sessionId {
                    onTap?(sessionId)
                }
            } label: {
                ticketCard(edition)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("오늘의 에디션: \(edition.subjectLine)")
            .accessibilityHint(edition.sessionId != nil ? "탭하여 오늘의 브리핑 열기" : "")
        }
    }

    private func ticketCard(_ edition: DailyNewsEdition) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Section (Header)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DAILY BRIEFING")
                        .font(.caption2.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(Color.dayreadInk.opacity(0.6))
                    
                    Text(formatEditionDate(edition.editionDate))
                        .font(.system(.caption, design: .serif))
                        .italic()
                        .foregroundStyle(Color.dayreadInk.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "newspaper.fill")
                    .font(.title3)
                    .foregroundStyle(Color.dayreadInk.opacity(0.2))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Perforated Line
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 16, height: 16)
                    .offset(x: -8)
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(Color.dayreadInk.opacity(0.1))
                    .frame(height: 1)
                
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 16, height: 16)
                    .offset(x: 8)
            }
            
            // Bottom Section (Content)
            VStack(alignment: .leading, spacing: 10) {
                Text(edition.subjectLine)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(Color.dayreadInk)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if !edition.introKo.isEmpty {
                    Text(edition.introKo)
                        .font(.caption)
                        .foregroundStyle(Color.dayreadInk.opacity(0.7))
                        .lineLimit(2)
                        .lineSpacing(2)
                }
                
                if edition.sessionId != nil {
                    HStack(spacing: 4) {
                        Text("READ NOW")
                            .font(.caption2.weight(.bold))
                            .tracking(1)
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.dayreadGold)
                    .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.dayreadInk.opacity(0.03))
                
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.dayreadInk.opacity(0.1), lineWidth: 1)
            }
        )
        .padding(.vertical, 8)
    }

    private func formatEditionDate(_ dateStr: String) -> String {
        guard let date = DateFormatters.parseISO(dateStr)
                ?? DateFormatters.shortDate.date(from: dateStr) else {
            return dateStr
        }
        return DateFormatters.displayDate.string(from: date)
    }
}

// Helper for dashed line
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}
