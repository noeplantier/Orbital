import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published var presentedError: IdentifiableError?

    private let authRepository: AuthRepository
    private let session: SessionStore

    init(authRepository: AuthRepository, session: SessionStore) {
        self.authRepository = authRepository
        self.session = session
        self.currentUser = session.currentUser
    }

    func logout() async {
        await authRepository.logout()
        session.handleSignedOut()
    }
}
