import Foundation

@Observable
final class UserService {
    private(set) var profile: ProfilePayload?
    private(set) var isLoading = false
    private(set) var error: Error?

    private let apiClient: APIClient

    var isLoggedIn: Bool { profile != nil }
    var isPremium: Bool { profile?.membershipTier == .premium }
    var isAdmin: Bool { profile?.isAdmin ?? false }
    var username: String { profile?.username ?? "" }
    var displayName: String { profile?.displayName ?? "" }
    var membershipTier: MembershipTier { profile?.membershipTier ?? .free }
    var dataKey: String { profile?.dataKey ?? "" }

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func loadProfile() async {
        isLoading = true
        error = nil

        do {
            let response = try await apiClient.fetchProfile()
            profile = response.profile
        } catch {
            AnalyticsService.captureError(error, context: "loadProfile")
            self.error = error
        }

        isLoading = false
    }

    func refreshProfile() async {
        do {
            let response = try await apiClient.fetchProfile()
            profile = response.profile
        } catch {
            AnalyticsService.captureError(error, context: "refreshProfile")
            self.error = error
        }
    }

    func updateProfile(_ newProfile: ProfilePayload) {
        profile = newProfile
    }

    func clearProfile() {
        profile = nil
        error = nil
    }
}
