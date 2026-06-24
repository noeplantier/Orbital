import Foundation

/// Abstraction over "who is signed in". Swap `MockAuthRepository` for a Firebase/Auth0/Cognito
/// backed implementation later without touching any ViewModel or View — see Data/Auth.
protocol AuthRepository: AnyObject {
    func login(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func logout() async
    func currentUser() async -> User?
}
