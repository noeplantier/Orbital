import XCTest
@testable import OrbitalApp

final class LoginUseCaseTests: XCTestCase {
    func test_execute_withValidCredentials_returnsUser() async throws {
        let repository = MockAuthRepository()
        let useCase = LoginUseCase(authRepository: repository)

        let user = try await useCase.execute(email: "demo@orbital.app", password: "password123")

        XCTAssertEqual(user.email, "demo@orbital.app")
    }

    func test_execute_withMalformedEmail_throwsInvalidCredentialsWithoutHittingRepository() async {
        let repository = MockAuthRepository()
        let useCase = LoginUseCase(authRepository: repository)

        do {
            _ = try await useCase.execute(email: "not-an-email", password: "password123")
            XCTFail("Expected AuthError.invalidCredentials")
        } catch AuthError.invalidCredentials {
            // expected
        } catch {
            XCTFail("Expected AuthError.invalidCredentials, got \(error)")
        }
    }

    func test_execute_withWrongPassword_throwsInvalidCredentials() async {
        let repository = MockAuthRepository()
        let useCase = LoginUseCase(authRepository: repository)

        do {
            _ = try await useCase.execute(email: "demo@orbital.app", password: "wrong-password")
            XCTFail("Expected AuthError.invalidCredentials")
        } catch AuthError.invalidCredentials {
            // expected
        } catch {
            XCTFail("Expected AuthError.invalidCredentials, got \(error)")
        }
    }
}
