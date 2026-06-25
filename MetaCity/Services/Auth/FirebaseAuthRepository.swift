import FirebaseAuth
import Foundation

/// Real Firebase Authentication backend — active automatically once `GoogleService-Info.plist` is
/// present and `FirebaseApp.configure()` has run (see `MetaCityApp.init` and
/// `AppEnvironment.defaultAuthRepository()`). Implements the exact same `AuthRepository` contract
/// as `MockAuthRepository`, so nothing in the Presentation layer needed to change to support this.
final class FirebaseAuthRepository: AuthRepository {
    func login(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return User(firebaseUser: result.user)
        } catch {
            throw AuthError.from(error)
        }
    }

    func signUp(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return User(firebaseUser: result.user)
        } catch {
            throw AuthError.from(error)
        }
    }

    func signInWithGoogle() async throws -> User {
        // Needs the GoogleSignIn-iOS SDK plus an OAuth client, neither of which are configured on
        // this Firebase project yet (no CLIENT_ID in GoogleService-Info.plist). Enable Google under
        // Firebase Console > Authentication > Sign-in method, re-download the plist, add the
        // GoogleSignIn-iOS package, then call `GIDSignIn.sharedInstance.signIn(...)` here and feed
        // the resulting idToken into `Auth.auth().signIn(with: GoogleAuthProvider.credential(...))`.
        throw AuthError.unknown("Sign in with Google isn't configured on this Firebase project yet.")
    }

    func logout() async {
        try? Auth.auth().signOut()
    }

    func currentUser() async -> User? {
        Auth.auth().currentUser.map(User.init(firebaseUser:))
    }
}

private extension User {
    init(firebaseUser: FirebaseAuth.User) {
        let localPart = firebaseUser.email?.split(separator: "@").first.map(String.init)
        self.init(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName ?? localPart ?? "User"
        )
    }
}

private extension AuthError {
    static func from(_ error: Error) -> AuthError {
        guard let code = AuthErrorCode(rawValue: (error as NSError).code) else {
            return .unknown(error.localizedDescription)
        }
        switch code {
        case .wrongPassword, .invalidEmail, .userNotFound, .invalidCredential:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .network
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
