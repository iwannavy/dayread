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
                    socialProofBanner
                    if !isPremium { planSelectionSection }
                    featureList
                    infoCard
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
            .onDisappear {
                AnalyticsService.track("paywall_dismissed")
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

    // MARK: - Social Proof

    private var socialProofBanner: some View {
        HStack(spacing: 0) {
            socialProofStat("97개+", label: "Original 콘텐츠")
            Spacer()
            socialProofDivider
            Spacer()
            socialProofStat("3,500+", label: "문장 분석")
            Spacer()
            socialProofDivider
            Spacer()
            socialProofStat("₩164", label: "하루 비용")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.dayreadGold.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }

    private func socialProofStat(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.dayreadGold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var socialProofDivider: some View {
        Rectangle()
            .fill(Color.dayreadGold.opacity(0.2))
            .frame(width: 1, height: 28)
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
            AnalyticsService.track("paywall_plan_selected", properties: [
                "plan": plan == .annual ? "annual" : "monthly"
            ])
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
        .accessibilityLabel("\(title) 구독 \(price), \(subtitle)\(badge.map { ", \($0)" } ?? "")\(selectedPlan == plan ? ", 현재 선택됨" : "")")
        .accessibilityAddTraits(selectedPlan == plan ? .isSelected : [])
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
            featureRow("4단계 딥리딩 학습법 (Immersive → Focus → Analysis → Review)")
            featureRow("3,500+ 문장 정밀 분석 콘텐츠")
            featureRow("GrammarViz 문법 시각화")
            featureRow("SRS 간격반복 복습 시스템")
            featureRow("프리미엄 데일리 레슨")
            featureRow("모든 커리큘럼 세션 잠금 해제")
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

        let planName = selectedPlan == .annual ? "annual" : "monthly"

        do {
            let customerInfo = try await subscriptionService.purchase(package: package)

            // 구매 성공 — 서버 동기화는 best-effort
            do {
                try await subscriptionService.syncWithServer(customerInfo: customerInfo, apiClient: apiClient)
            } catch {
                #if DEBUG
                print("[PaywallView] syncWithServer failed (purchase OK): \(error)")
                #endif
            }

            async let _ = userService.loadProfile()
            async let _ = libraryService.reloadLibrary()

            HapticsService.shared.success()
            AnalyticsService.track("purchase_completed", properties: ["plan": planName])

            if customerInfo.entitlements["premium"]?.periodType == .trial {
                AnalyticsService.track("free_trial_started", properties: ["plan": planName])
            }

            onSuccess?()
            dismiss()
        } catch let err as SubscriptionError where err == .userCancelled {
            // User cancelled — do nothing
        } catch {
            AnalyticsService.track("purchase_failed", properties: [
                "plan": planName, "error": error.localizedDescription
            ])
            self.error = error.localizedDescription
        }

        loadingAction = nil
    }

    private func handleRestore() async {
        loadingAction = .restore
        error = nil

        do {
            let customerInfo = try await subscriptionService.restorePurchases()

            // 복원 성공 — 서버 동기화는 best-effort
            do {
                try await subscriptionService.syncWithServer(customerInfo: customerInfo, apiClient: apiClient)
            } catch {
                #if DEBUG
                print("[PaywallView] syncWithServer failed (restore OK): \(error)")
                #endif
            }

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
