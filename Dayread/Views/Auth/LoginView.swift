import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthService.self) private var authService
    @Environment(ToastService.self) private var toast

    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo & Title
            VStack(spacing: 16) {
                Image(systemName: "book.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.dayreadGold)

                Text("Dayread")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(.primary)

                Text("매일 한 편의 영어, 깊이 있는 학습")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Sign In Buttons
            VStack(spacing: 12) {
                // Apple Sign In
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            }
            .padding(.horizontal, 24)
            .disabled(isLoading)

            // Guest
            Button {
                authService.continueAsGuest()
            } label: {
                Text("로그인 없이 둘러보기")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 16)

            // Footer
            VStack(spacing: 4) {
                Text("계속 진행하면")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                HStack(spacing: 4) {
                    Link("이용약관", destination: URL(string: "https://dayread.day/terms")!)
                    Text("및")
                        .foregroundStyle(.tertiary)
                    Link("개인정보 처리방침", destination: URL(string: "https://dayread.day/privacy")!)
                    Text("에 동의합니다.")
                        .foregroundStyle(.tertiary)
                }
                .font(.caption2)
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color.dayreadCream)
        .overlay {
            if isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                toast.showError("Apple 로그인에 실패했습니다.")
                return
            }

            isLoading = true
            Task {
                do {
                    try await authService.signInWithApple(credential: appleCredential)
                } catch {
                    toast.showError("로그인 실패: \(error.localizedDescription)")
                }
                isLoading = false
            }

        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                toast.showError("Apple 로그인에 실패했습니다: \(error.localizedDescription)")
            }
        }
    }
}
