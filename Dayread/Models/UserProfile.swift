import Foundation

enum MembershipTier: String, Codable {
    case free, premium
}

enum MembershipSource: String, Codable {
    case profile
    case mockIap = "mock_iap"
    case adminPreview = "admin_preview"
}

enum AccountRole: String, Codable {
    case member, admin
}

enum AdminMembershipPreview: String, Codable {
    case base, free, premium
}

enum AuthProvider: String, Codable {
    case email, google, apple, legacy
}

struct ConnectedAuthProvider: Codable {
    let provider: AuthProvider
    let isPrimary: Bool
}

struct QuickProfileStats: Codable {
    let streak: Int
    let totalSentencesStudied: Int
    let totalExercisesCompleted: Int
    let totalWritings: Int
    let openedPremiumLessons: Int
}

struct MockMembershipState: Codable {
    let status: String
    let plan: String
    let priceKrw: Int
    let activatedAt: String?
    let restoredAt: String?
    let cancelledAt: String?
    let source: String
}

struct ProfilePayload: Codable {
    let id: String
    let username: String
    let displayName: String
    let dataKey: String
    let accountRole: AccountRole
    let isAdmin: Bool
    let membershipTier: MembershipTier
    let baseMembershipTier: MembershipTier
    let membershipSource: MembershipSource
    let mockMembership: MockMembershipState
    let linkedProviders: [ConnectedAuthProvider]
    let subscription: SubscriptionSummary?
    let canDeleteAccount: Bool
    let stats: QuickProfileStats
}
