import FirebaseCore
import Foundation

/// Simple, explicit dependency container — a lightweight alternative to a full DI framework like
/// Resolver/Swinject. Every dependency is exposed only as its Domain protocol type, so swapping
/// `MockAuthRepository` for `FirebaseAuthRepository` was a one-line change here and nowhere else.
@MainActor
final class AppEnvironment {
    let authRepository: AuthRepository
    let mapRepository: MapRepository
    let callService: CallService
    let locationProvider: UserLocationProvider

    init(
        authRepository: AuthRepository = AppEnvironment.defaultAuthRepository(),
        mapRepository: MapRepository = MockMapRepository(),
        callService: CallService = MockCallService(),
        locationProvider: UserLocationProvider = CoreLocationProvider()
    ) {
        self.authRepository = authRepository
        self.mapRepository = mapRepository
        self.callService = callService
        self.locationProvider = locationProvider
    }

    /// Picks the real Firebase-backed repository when `FirebaseApp.configure()` has already run
    /// (i.e. a `GoogleService-Info.plist` was present at launch — see `MetaCityApp.init`),
    /// otherwise falls back to the in-memory mock. This is what keeps "clone and run" working for
    /// anyone without that file, instead of crashing on launch.
    private nonisolated static func defaultAuthRepository() -> AuthRepository {
        FirebaseApp.app() != nil ? FirebaseAuthRepository() : MockAuthRepository()
    }

    // MARK: - Feature ViewModel factories
    // Each screen's dependencies are assembled in exactly one place. Add e.g. a
    // `makePushNotificationsViewModel()` or `makeAnalyticsService()` here when those features land.

    func makeAuthViewModel(session: SessionStore) -> AuthViewModel {
        AuthViewModel(
            authRepository: authRepository,
            loginUseCase: LoginUseCase(authRepository: authRepository),
            session: session
        )
    }

    func makeExploreViewModel(session: SessionStore) -> ExploreViewModel {
        ExploreViewModel(mapRepository: mapRepository, currentUserName: session.currentUser?.displayName)
    }

    func makeMapViewModel() -> MapViewModel {
        MapViewModel(mapRepository: mapRepository, locationProvider: locationProvider)
    }

    func makeARViewModel() -> ARViewModel {
        ARViewModel()
    }

    func makeCallViewModel() -> CallViewModel {
        CallViewModel(
            callService: callService,
            joinCallUseCase: JoinCallUseCase(callService: callService)
        )
    }

    func makeLandmarkInspectorViewModel() -> LandmarkInspectorViewModel {
        LandmarkInspectorViewModel()
    }

    func makeProfileViewModel(session: SessionStore) -> ProfileViewModel {
        ProfileViewModel(authRepository: authRepository, session: session)
    }
}
