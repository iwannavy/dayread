import SwiftUI

// MARK: - Shimmer Effect (for Skeleton UI)

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = -0.3

    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                    startPoint: .init(x: phase, y: phase),
                    endPoint: .init(x: phase + 0.3, y: phase + 0.3)
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1.0
                }
            }
    }
}

// MARK: - Staggered Appear (for Sequential Transitions)

struct StaggeredAppearModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 15)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Highlight Effect (for Grammar Visualization)

struct HighlightEffect: ViewModifier {
    let isActive: Bool
    let color: Color

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(color.opacity(0.15))
                            .frame(width: isActive ? geo.size.width : 0)
                    }
                }
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
    }
}

// MARK: - Collection Safe Subscript

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - View Extensions

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }

    func staggeredAppear(delay: Double) -> some View {
        self.modifier(StaggeredAppearModifier(delay: delay))
    }

    func grammarHighlight(isActive: Bool, color: Color) -> some View {
        self.modifier(HighlightEffect(isActive: isActive, color: color))
    }
}
