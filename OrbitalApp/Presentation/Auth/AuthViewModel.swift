import Foundation

enum AuthMode: Equatable {
    case login
    case signUp

    var toggleTitle: String {
        switch self {
        case .login: return "Need an account? Sign up"
        case .signUp: return "Already have an account? Log in"
        }
    }

    var submitTitle: String {
        switch self {
        case .login: return "Log In"
        case .signUp: return "Sign Up"
        }
    }
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var mode: AuthMode = .login
    @Published var isLoading = false
    @Published var presentedError: IdentifiableError?

    private let authRepository: AuthRepository
    private let loginUseCase: LoginUseCase
    private let session: SessionStore

    init(authRepository: AuthRepository, loginUseCase: LoginUseCase, session: SessionStore) {
        self.authRepository = authRepository
        self.loginUseCase = loginUseCase
        self.session = session
    }

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }

    func toggleMode() {
        mode = (mode == .login) ? .signUp : .login
        presentedError = nil
    }

    /// Login goes through `LoginUseCase` for basic validation; sign-up calls the repository
    /// directly since the mock backend already enforces its own rule (`AuthError.weakPassword`).
    func submit() async {
        guard canSubmit else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let user: User
            switch mode {
            case .login:
                user = try await loginUseCase.execute(email: email, password: password)
            case .signUp:
                user = try await authRepository.signUp(email: email, password: password)
            }
            session.handleSignedIn(user)
        } catch {
            presentedError = IdentifiableError(underlyingError: error)
        }
    }
}
