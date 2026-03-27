import SwiftUI

struct DeleteAccountSection: View {
    @Environment(APIClient.self) private var apiClient
    @Environment(AuthService.self) private var authService
    @Environment(ToastService.self) private var toast

    @State private var showConfirmation = false
    @State private var isDeleting = false

    var body: some View {
        Section {
            Button(role: .destructive) {
                showConfirmation = true
            } label: {
                HStack {
                    Label("계정 삭제", systemImage: "trash")
                    if isDeleting {
                        Spacer()
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .disabled(isDeleting)
            .confirmationDialog(
                "계정을 삭제하시겠습니까?",
                isPresented: $showConfirmation,
                titleVisibility: .visible
            ) {
                Button("계정 삭제", role: .destructive) {
                    Task { await deleteAccount() }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("삭제된 계정은 복구할 수 없습니다. 모든 학습 데이터와 작성 기록이 영구적으로 삭제됩니다.")
            }
        } footer: {
            Text("계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.")
                .font(.caption)
        }
    }

    private func deleteAccount() async {
        isDeleting = true
        defer { isDeleting = false }

        do {
            try await apiClient.deleteAccount()
            try? await authService.signOut()
            toast.show("계정이 삭제되었습니다")
        } catch {
            toast.showError("계정 삭제에 실패했습니다: \(error.localizedDescription)")
        }
    }
}
