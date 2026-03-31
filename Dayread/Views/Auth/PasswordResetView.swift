import SwiftUI

struct PasswordResetView: View {
    @Environment(AuthService.self) private var authService
    @Environment(ToastService.self) private var toast
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("가입 시 사용한 이메일을 입력하면\n비밀번호 재설정 링크를 보내드립니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                TextField("이메일", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)

                Button {
                    Task { await resetPassword() }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("재설정 링크 보내기")
                        }
                    }
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(.white)
                    .background(email.contains("@") ? Color.dayreadGold : Color.dayreadGold.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLoading || !email.contains("@"))
                .padding(.horizontal, 24)

                Spacer()
            }
            .background(Color.dayreadCream)
            .navigationTitle("비밀번호 재설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }

    private func resetPassword() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.resetPassword(email: email)
            toast.showSuccess("재설정 링크가 발송되었습니다. 이메일을 확인해주세요.")
            AnalyticsService.track("password_reset_requested")
            dismiss()
        } catch {
            toast.showError("비밀번호 재설정에 실패했습니다. 이메일을 확인해주세요.")
            AnalyticsService.captureError(error, context: "password_reset")
        }
    }
}
