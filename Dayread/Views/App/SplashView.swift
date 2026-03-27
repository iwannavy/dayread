import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.dayreadGold)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.5)

            Text("Dayread")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .opacity(isAnimating ? 1.0 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dayreadCream)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}
