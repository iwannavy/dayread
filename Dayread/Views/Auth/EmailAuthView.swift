import SwiftUI

struct EmailAuthView: View {
    @Environment(AuthService.self) private var authService
    @Environment(ToastService.self) private var toast
    @Environment(\.dismiss) private var dismiss

    enum Mode: String, CaseIterable {
        case signIn = "로그인"
        case signUp = "회원가입"
    }

    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showResetPassword = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                SlidingTabPicker(selection: $mode, items: Mode.allCases)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                VStack(spacing: 14) {
                    TextField("이메일", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("비밀번호", text: $password)
                        .textContentType(mode == .signUp ? .newPassword : .password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if mode == .signUp {
                        SecureField("비밀번호 확인", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)

                Button {
                    Task { await submit() }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(mode == .signIn ? "로그인" : "회원가입")
                        }
                    }
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(.white)
                    .background(isFormValid ? Color.dayreadGold : Color.dayreadGold.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLoading || !isFormValid)
                .padding(.horizontal, 24)

                if mode == .signIn {
                    Button {
                        showResetPassword = true
                    } label: {
                        Text("비밀번호를 잊으셨나요?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .background(Color.dayreadCream)
            .navigationTitle(mode == .signIn ? "이메일 로그인" : "이메일 회원가입")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
            .sheet(isPresented: $showResetPassword) {
                PasswordResetView()
            }
            .onChange(of: mode) { _, _ in
                confirmPassword = ""
            }
        }
    }

    private var isFormValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")
        let passwordValid = password.count >= 6
        if mode == .signUp {
            return emailValid && passwordValid && password == confirmPassword
        }
        return emailValid && passwordValid
    }

    private func submit() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if mode == .signIn {
                try await authService.signInWithEmail(email: email, password: password)
                AnalyticsService.track("login_success", properties: ["method": "email"])
                dismiss()
            } else {
                try await authService.signUpWithEmail(email: email, password: password)
                AnalyticsService.track("signup_success", properties: ["method": "email"])
                dismiss()
            }
        } catch let error as AuthService.AuthError where error == .emailConfirmationRequired {
            toast.showSuccess("인증 이메일이 발송되었습니다. 이메일을 확인해주세요.")
            dismiss()
        } catch {
            toast.showError(mapEmailAuthError(error))
            AnalyticsService.captureError(error, context: mode == .signIn ? "email_sign_in" : "email_sign_up")
        }
    }

    private func mapEmailAuthError(_ error: Error) -> String {
        let desc = error.localizedDescription.lowercased()
        if desc.contains("invalid login credentials") || desc.contains("invalid_credentials") {
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        }
        if desc.contains("user already registered") || desc.contains("already_exists") {
            return "이미 가입된 이메일입니다. 로그인해주세요."
        }
        if desc.contains("password") && desc.contains("short") {
            return "비밀번호는 6자 이상이어야 합니다."
        }
        if desc.contains("rate limit") || desc.contains("too many") {
            return "잠시 후 다시 시도해주세요."
        }
        return "로그인에 실패했습니다. 다시 시도해주세요."
    }
}
