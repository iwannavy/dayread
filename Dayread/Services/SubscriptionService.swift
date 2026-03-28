import Foundation
import RevenueCat

@Observable
final class SubscriptionService {
    // MARK: - State

    private(set) var isConfigured = false
    private(set) var isPurchasing = false
    private(set) var monthlyPackage: Package?
    private(set) var annualPackage: Package?
    private(set) var error: String?

    // MARK: - Configure

    func configure(apiKey: String, appUserID: String? = nil) {
        guard !apiKey.isEmpty, !isConfigured else { return }

        Purchases.logLevel = .warn
        if let appUserID {
            Purchases.configure(withAPIKey: apiKey, appUserID: appUserID)
        } else {
            Purchases.configure(withAPIKey: apiKey)
        }
        isConfigured = true
    }

    /// Log in authenticated user to RevenueCat
    func login(appUserID: String) async throws {
        guard isConfigured else { return }
        _ = try await Purchases.shared.logIn(appUserID)
    }

    /// Log out (switch to anonymous user)
    func logout() async throws {
        guard isConfigured else { return }
        _ = try await Purchases.shared.logOut()
    }

    // MARK: - Offerings

    func fetchOfferings() async {
        guard isConfigured else { return }

        do {
            let offerings = try await Purchases.shared.offerings()
            let current = offerings.current

            monthlyPackage = current?.monthly
            annualPackage = current?.annual
        } catch {
            AnalyticsService.captureError(error, context: "fetchOfferings")
            self.error = "상품 정보를 불러올 수 없습니다."
        }
    }

    // MARK: - Purchase

    func purchase(package: Package) async throws -> CustomerInfo {
        guard isConfigured else {
            throw SubscriptionError.notConfigured
        }

        isPurchasing = true
        error = nil
        defer { isPurchasing = false }

        let result = try await Purchases.shared.purchase(package: package)

        if result.userCancelled {
            throw SubscriptionError.userCancelled
        }

        return result.customerInfo
    }

    // MARK: - Restore

    func restorePurchases() async throws -> CustomerInfo {
        guard isConfigured else {
            throw SubscriptionError.notConfigured
        }

        isPurchasing = true
        error = nil
        defer { isPurchasing = false }

        let customerInfo = try await Purchases.shared.restorePurchases()

        let hasPremium = customerInfo.entitlements["premium"]?.isActive == true
        if !hasPremium {
            throw SubscriptionError.noActiveSubscription
        }

        return customerInfo
    }

    // MARK: - Server Sync

    /// Sync purchase result with Dayread server
    func syncWithServer(customerInfo: CustomerInfo, apiClient: APIClient) async throws {
        let info = customerInfoToDict(customerInfo)
        _ = try await apiClient.refreshSubscription(customerInfo: info)
    }

    // MARK: - Helpers

    var monthlyPriceDisplay: String {
        monthlyPackage?.localizedPriceString ?? "₩7,900"
    }

    var annualPriceDisplay: String {
        annualPackage?.localizedPriceString ?? "₩59,900"
    }

    var annualMonthlyEquivalent: String {
        if let price = annualPackage?.storeProduct.price as? NSDecimalNumber {
            let monthly = price.dividing(by: 12)
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.maximumFractionDigits = 0
            return formatter.string(from: monthly) ?? "₩4,992"
        }
        return "₩4,992"
    }

    var annualSavingsPercent: Int {
        guard let monthly = monthlyPackage?.storeProduct.price as? NSDecimalNumber,
              let annual = annualPackage?.storeProduct.price as? NSDecimalNumber else {
            return 37  // fallback
        }
        let yearlyAtMonthly = monthly.multiplying(by: 12)
        if yearlyAtMonthly.doubleValue == 0 { return 0 }
        let savings = 1.0 - annual.doubleValue / yearlyAtMonthly.doubleValue
        return Int(round(savings * 100))
    }

    private func customerInfoToDict(_ info: CustomerInfo) -> [String: Any] {
        var dict: [String: Any] = [
            "originalAppUserId": info.originalAppUserId,
            "activeSubscriptions": Array(info.activeSubscriptions),
        ]

        var entitlements: [String: Any] = [:]
        for (key, entitlement) in info.entitlements.all {
            entitlements[key] = [
                "identifier": entitlement.identifier,
                "isActive": entitlement.isActive,
                "productIdentifier": entitlement.productIdentifier,
                "expirationDate": entitlement.expirationDate?.ISO8601Format() as Any,
                "willRenew": entitlement.willRenew,
                "isSandbox": entitlement.isSandbox,
            ]
        }
        dict["entitlements"] = entitlements

        return dict
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case notConfigured
    case userCancelled
    case noActiveSubscription

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "구독 서비스가 초기화되지 않았습니다."
        case .userCancelled:
            return nil  // Don't show error for user cancellation
        case .noActiveSubscription:
            return "복원할 활성 구독을 찾을 수 없습니다."
        }
    }
}
