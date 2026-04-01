import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct LoginView: View {
    @Environment(AuthService.self) private var authService
    @Environment(ToastService.self) private var toast

    @State private var isLoading = false
    @State private var showEmailAuth = false

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

                // Google Sign In
                Button {
                    handleGoogleSignIn()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                        Text("Google로 계속하기")
                            .font(.body.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.systemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                }

                // Email Sign In
                Button {
                    showEmailAuth = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .font(.title2)
                        Text("이메일로 계속하기")
                            .font(.body.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.systemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                }
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
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView()
        }
    }

    // MARK: - Apple Sign In

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

    // MARK: - Google Sign In

    private func handleGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            toast.showError("Google 로그인을 시작할 수 없습니다.")
            return
        }

        isLoading = true
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            Task { @MainActor in
                defer { isLoading = false }

                if let error {
                    if (error as NSError).code != GIDSignInError.canceled.rawValue {
                        toast.showError("Google 로그인에 실패했습니다.")
                        AnalyticsService.captureError(error, context: "google_sign_in")
                    }
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    toast.showError("Google 인증 정보를 가져올 수 없습니다.")
                    return
                }

                do {
                    try await authService.signInWithGoogle(
                        idToken: idToken,
                        accessToken: user.accessToken.tokenString
                    )
                    AnalyticsService.track("login_success", properties: ["method": "google"])
                } catch {
                    toast.showError("로그인 실패: \(error.localizedDescription)")
                    AnalyticsService.captureError(error, context: "google_sign_in_supabase")
                }
            }
        }
    }

}
