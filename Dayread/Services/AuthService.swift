import Foundation
import Supabase
import AuthenticationServices

@Observable
final class AuthService {
    enum AuthState {
        case loading
        case authenticated(userId: String)
        case guest
        case unauthenticated
    }

    private(set) var state: AuthState = .loading
    private let supabase: SupabaseClient
    private var authListener: Task<Void, Never>?

    var isAuthenticated: Bool {
        if case .authenticated = state { return true }
        return false
    }

    var isGuest: Bool {
        if case .guest = state { return true }
        return false
    }

    var userId: String? {
        if case .authenticated(let id) = state { return id }
        return nil
    }

    init() {
        self.supabase = SupabaseClient(
            supabaseURL: AppConstants.Supabase.url,
            supabaseKey: AppConstants.Supabase.anonKey,
            options: .init(auth: .init(emitLocalSessionAsInitialSession: true))
        )
    }

    func start() {
        authListener = Task { [weak self] in
            guard let self else { return }

            for await (event, session) in supabase.auth.authStateChanges {
                switch event {
                case .initialSession:
                    if let session, !session.isExpired {
                        self.state = .authenticated(userId: session.user.id.uuidString)
                    } else {
                        self.state = .unauthenticated
                    }
                case .signedIn:
                    if let session {
                        self.state = .authenticated(userId: session.user.id.uuidString)
                    }
                case .signedOut:
                    self.state = .unauthenticated
                case .tokenRefreshed:
                    if let session {
                        self.state = .authenticated(userId: session.user.id.uuidString)
                    }
                default:
                    break
                }
            }
        }
    }

    func stop() {
        authListener?.cancel()
        authListener = nil
    }

    deinit {
        authListener?.cancel()
    }

    // MARK: - Access Token

    func accessToken() async throws -> String {
        let session = try await supabase.auth.session
        return session.accessToken
    }

    // MARK: - Sign In with Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: tokenString
            )
        )
    }

    // MARK: - Sign In with Google

    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken,
                accessToken: accessToken
            )
        )
    }

    // MARK: - Guest

    func continueAsGuest() {
        state = .guest
    }

    // MARK: - Email Auth

    func signInWithEmail(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    func signUpWithEmail(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(email: email, password: password)
        if response.session == nil {
            throw AuthError.emailConfirmationRequired
        }
    }

    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }

    // MARK: - Sign Out

    func signOut() async throws {
        if case .guest = state {
            state = .unauthenticated
            return
        }
        try await supabase.auth.signOut()
        state = .unauthenticated
    }

    // MARK: - Errors

    enum AuthError: LocalizedError {
        case invalidCredential
        case noSession
        case emailConfirmationRequired

        var errorDescription: String? {
            switch self {
            case .invalidCredential: return "잘못된 인증 정보입니다."
            case .noSession: return "세션이 만료되었습니다. 다시 로그인해주세요."
            case .emailConfirmationRequired: return "인증 이메일이 발송되었습니다. 이메일을 확인해주세요."
            }
        }
    }
}
