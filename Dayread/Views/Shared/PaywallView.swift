import SwiftUI
import RevenueCat

struct PaywallView: View {
    var onSuccess: (() -> Void)?

    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(UserService.self) private var userService
    @Environment(LibraryService.self) private var libraryService
    @Environment(APIClient.self) private var apiClient
    @Environment(ToastService.self) private var toast
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: SelectedPlan = .annual
    @State private var loadingAction: LoadingAction?
    @State private var error: String?

    private enum SelectedPlan {
        case monthly, annual
    }

    private enum LoadingAction {
        case purchase, restore
    }

    private var isPremium: Bool {
        userService.isPremium
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    if !isPremium { planSelectionSection }
                    infoCard
                    featureList
                    if let error { errorMessage(error) }
                    actionButtons
                    subscriptionStatus
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("프리미엄 업그레이드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
            .task {
                AnalyticsService.track("paywall_shown")
                await subscriptionService.fetchOfferings()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.dayreadGold)

            Text("전체 학습 라이브러리와 프리미엄 데일리 아카이브를 잠금 해제하세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Plan Selection

    private var planSelectionSection: some View {
        HStack(spacing: 12) {
            planButton(
                title: "월간",
                price: subscriptionService.monthlyPriceDisplay,
                subtitle: "/월",
                plan: .monthly,
                badge: nil
            )

            planButton(
                title: "연간",
                price: subscriptionService.annualPriceDisplay,
                subtitle: "월 \(subscriptionService.annualMonthlyEquivalent)",
                plan: .annual,
                badge: subscriptionService.annualSavingsPercent > 0
                    ? "\(subscriptionService.annualSavingsPercent)% OFF"
                    : nil
            )
        }
    }

    private func planButton(title: String, price: String, subtitle: String, plan: SelectedPlan, badge: String?) -> some View {
        Button {
            selectedPlan = plan
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(price)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedPlan == plan ? Color.dayreadGold.opacity(0.1) : Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == plan ? Color.dayreadGold : Color(.separator), lineWidth: selectedPlan == plan ? 2 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.dayreadGold, in: Capsule())
                        .offset(x: -8, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Info Card

    private var infoCard: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("APP STORE 구독")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text("7일 무료 체험 포함. 언제든 해지 가능.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("iOS")
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.dayreadGold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.dayreadGold.opacity(0.15), in: Capsule())
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Feature List

    private var featureList: some View {
        VStack(spacing: 8) {
            featureRow("모든 커리큘럼 세션 잠금 해제")
            featureRow("프리미엄 데일리 레슨 열람 (활성 기간 내)")
            featureRow("구독 상태가 대시보드·학습·프로필에 자동 반영")
        }
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(Color.dayreadGold)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Error

    private func errorMessage(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            if isPremium {
                restoreButton
                manageSubscriptionButton
            } else {
                purchaseButton
                restoreButton
            }
        }
    }

    private var purchaseButton: some View {
        Button {
            Task { await handlePurchase() }
        } label: {
            Group {
                if loadingAction == .purchase {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                        Text("App Store 연결 중...")
                    }
                } else {
                    Text("무료 체험 시작")
                }
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundStyle(.white)
            .background(Color.dayreadGold, in: RoundedRectangle(cornerRadius: 12))
        }
        .disabled(loadingAction != nil)
    }

    private var restoreButton: some View {
        Button {
            Task { await handleRestore() }
        } label: {
            Group {
                if loadingAction == .restore {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("복원 중...")
                    }
                } else {
                    Text("구매 복원")
                }
            }
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        }
        .disabled(loadingAction != nil)
    }

    private var manageSubscriptionButton: some View {
        Button {
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                UIApplication.shared.open(url)
            }
            dismiss()
        } label: {
            Text("구독 관리")
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle(.secondary)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Subscription Status

    @ViewBuilder
    private var subscriptionStatus: some View {
        if let subscription = userService.profile?.subscription,
           subscription.provider == .appStore {
            Text("현재 구독 상태: \(subscription.status.rawValue)\(subscription.expiresAt.map { " · \($0.prefix(10))" } ?? "")")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Actions

    private func handlePurchase() async {
        let package = selectedPlan == .annual
            ? subscriptionService.annualPackage
            : subscriptionService.monthlyPackage

        guard let package else {
            error = "상품 정보를 불러올 수 없습니다. 다시 시도해주세요."
            return
        }

        loadingAction = .purchase
        error = nil

        do {
            let customerInfo = try await subscriptionService.purchase(package: package)
            try await subscriptionService.syncWithServer(customerInfo: customerInfo, apiClient: apiClient)

            async let _ = userService.loadProfile()
            async let _ = libraryService.reloadLibrary()

            HapticsService.shared.success()
            AnalyticsService.track("purchase_completed", properties: [
                "plan": selectedPlan == .annual ? "annual" : "monthly"
            ])
            onSuccess?()
            dismiss()
        } catch let err as SubscriptionError where err == .userCancelled {
            // User cancelled — do nothing
        } catch {
            self.error = error.localizedDescription
        }

        loadingAction = nil
    }

    private func handleRestore() async {
        loadingAction = .restore
        error = nil

        do {
            let customerInfo = try await subscriptionService.restorePurchases()
            try await subscriptionService.syncWithServer(customerInfo: customerInfo, apiClient: apiClient)

            async let _ = userService.loadProfile()
            async let _ = libraryService.reloadLibrary()

            HapticsService.shared.success()
            toast.show("구독이 복원되었습니다.", type: .success)
            onSuccess?()
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }

        loadingAction = nil
    }
}
