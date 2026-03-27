import SwiftUI

struct OnboardingView: View {
    @Environment(PreferencesService.self) private var preferencesService
    @State private var currentPage = 0

    private let slides: [(icon: String, title: String, description: String)] = [
        ("text.book.closed.fill", "깊이 있는 영어 학습", "뉴스, 에세이, 연설문을 문장 단위로 해체하고 분석합니다."),
        ("waveform.badge.mic", "듣고 말하기", "원어민 TTS로 듣고, 쉐도잉으로 발음을 연습합니다."),
        ("pencil.and.outline", "쓰기 코치", "AI가 영작문을 분석하고 피드백을 제공합니다."),
        ("flame.fill", "매일 학습 습관", "스트릭을 유지하며 꾸준히 영어 실력을 키웁니다."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: slide.icon)
                            .font(.system(size: 72))
                            .foregroundStyle(Color.dayreadGold)
                            .symbolEffect(.bounce, value: currentPage == index)

                        Text(slide.title)
                            .font(.title.bold())

                        Text(slide.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            // Bottom Button
            Button {
                if currentPage < slides.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    preferencesService.setOnboardingComplete()
                }
            } label: {
                Text(currentPage < slides.count - 1 ? "다음" : "시작하기")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.dayreadGold)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            if currentPage < slides.count - 1 {
                Button("건너뛰기") {
                    preferencesService.setOnboardingComplete()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
            }
        }
        .background(Color.dayreadCream)
    }
}
