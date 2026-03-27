import SwiftUI

struct ProfileView: View {
    @Environment(UserService.self) private var userService
    @Environment(AuthService.self) private var authService
    @Environment(PreferencesService.self) private var preferencesService
    @Environment(APIClient.self) private var apiClient
    @Environment(ToastService.self) private var toast

    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var isSavingName = false

    private var profile: ProfilePayload? { userService.profile }

    var body: some View {
        List {
            profileHeaderSection
            membershipSection
            statsSection
            linkedProvidersSection
            AppSettingsView()
            legalSection
            accountSection
        }
        .navigationTitle("프로필")
        .task {
            if !preferencesService.isLoaded {
                await preferencesService.load()
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeaderSection: some View {
        Section {
            HStack(spacing: 14) {
                // Avatar
                Circle()
                    .fill(Color.dayreadGold)
                    .frame(width: 56, height: 56)
                    .overlay {
                        Text(String(userService.displayName.prefix(1)).uppercased())
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    if isEditingName {
                        nameEditField
                    } else {
                        HStack(spacing: 8) {
                            Text(userService.displayName)
                                .font(.headline)

                            Button {
                                editedName = userService.displayName
                                isEditingName = true
                            } label: {
                                Image(systemName: "pencil.circle")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.dayreadGold)
                            }
                        }
                    }

                    Text("@\(userService.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var nameEditField: some View {
        HStack(spacing: 8) {
            TextField("닉네임", text: $editedName)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
                .submitLabel(.done)
                .onSubmit { Task { await saveName() } }

            Button("저장") {
                Task { await saveName() }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.dayreadGold)
            .disabled(editedName.trimmingCharacters(in: .whitespaces).isEmpty || isSavingName)

            Button("취소") {
                isEditingName = false
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Membership

    private var membershipSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(userService.isPremium ? "Premium" : "Free")
                        .font(.headline)
                        .foregroundStyle(userService.isPremium ? Color.dayreadGold : .primary)

                    Spacer()

                    if let tier = profile?.baseMembershipTier {
                        Text(tier == .premium ? "활성" : "무료")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(tier == .premium ? .green : .secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(tier == .premium ? .green.opacity(0.12) : Color(.systemGray5)))
                    }
                }

                if let subscription = profile?.subscription {
                    if let expiresAt = subscription.expiresAt {
                        Text("만료: \(formatDate(expiresAt))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("결제 수단: \(subscription.provider?.displayName ?? "알 수 없음")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if !userService.isPremium {
                    Text("프리미엄으로 업그레이드하면 전체 커리큘럼과 프리미엄 콘텐츠를 이용할 수 있습니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("멤버십")
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        Section("통계") {
            let stats = profile?.stats

            LabeledContent("연속 학습", value: "\(stats?.streak ?? 0)일")
            LabeledContent("학습 문장", value: "\(stats?.totalSentencesStudied ?? 0)개")
            LabeledContent("연습 완료", value: "\(stats?.totalExercisesCompleted ?? 0)개")
            LabeledContent("영작 완료", value: "\(stats?.totalWritings ?? 0)개")
            LabeledContent("프리미엄 열람", value: "\(stats?.openedPremiumLessons ?? 0)개")
        }
    }

    // MARK: - Linked Providers

    private var linkedProvidersSection: some View {
        Section("연결된 계정") {
            if let providers = profile?.linkedProviders {
                ForEach(providers, id: \.provider) { linked in
                    HStack {
                        Image(systemName: providerIcon(linked.provider))
                            .frame(width: 24)
                        Text(providerName(linked.provider))
                        if linked.isPrimary {
                            Text("· 기본")
                                .font(.caption)
                                .foregroundStyle(Color.dayreadGold)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Legal & Info

    private var legalSection: some View {
        Section("정보") {
            Link(destination: URL(string: "https://dayread.day/privacy")!) {
                Label("개인정보처리방침", systemImage: "hand.raised")
            }

            Link(destination: URL(string: "https://dayread.day/terms")!) {
                Label("이용약관", systemImage: "doc.text")
            }

            HStack {
                Label("앱 버전", systemImage: "info.circle")
                Spacer()
                Text(appVersionString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }

    // MARK: - Account Management

    private var accountSection: some View {
        Group {
            Section {
                Button("로그아웃", role: .destructive) {
                    Task {
                        try? await authService.signOut()
                        toast.show("로그아웃되었습니다")
                    }
                }
            }

            if profile?.canDeleteAccount == true {
                DeleteAccountSection()
            }
        }
    }

    // MARK: - Helpers

    private func saveName() async {
        let trimmed = editedName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isSavingName = true
        defer { isSavingName = false }

        do {
            let response = try await apiClient.updateDisplayName(trimmed)
            userService.updateProfile(response.profile)
            isEditingName = false
            toast.show("닉네임이 변경되었습니다")
        } catch {
            toast.showError("닉네임 변경에 실패했습니다")
        }
    }

    private func formatDate(_ iso: String) -> String {
        guard let date = DateFormatters.parseISO(iso) else { return iso }
        return DateFormatters.displayDate.string(from: date)
    }

    private func providerIcon(_ provider: AuthProvider) -> String {
        switch provider {
        case .apple: return "apple.logo"
        case .google: return "g.circle"
        case .email: return "envelope"
        case .legacy: return "person.badge.key"
        }
    }

    private func providerName(_ provider: AuthProvider) -> String {
        switch provider {
        case .apple: return "Apple"
        case .google: return "Google"
        case .email: return "이메일"
        case .legacy: return "레거시"
        }
    }
}

// MARK: - SubscriptionProvider Display

extension SubscriptionProvider {
    var displayName: String {
        switch self {
        case .appStore: return "App Store"
        case .playStore: return "Google Play"
        case .mockIap: return "Test"
        }
    }
}
