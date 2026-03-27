import Foundation

enum SubscriptionProvider: String, Codable {
    case appStore = "app_store"
    case playStore = "play_store"
    case mockIap = "mock_iap"
}

enum SubscriptionStatus: String, Codable {
    case inactive, active, cancelled, expired
}

enum SubscriptionEnvironment: String, Codable {
    case sandbox, production
}

struct SubscriptionSummary: Codable {
    let provider: SubscriptionProvider?
    let status: SubscriptionStatus
    let productId: String?
    let entitlementId: String?
    let expiresAt: String?
    let environment: SubscriptionEnvironment?
}
