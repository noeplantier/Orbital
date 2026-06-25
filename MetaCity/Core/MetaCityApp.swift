import FirebaseCore
import SwiftUI

@main
struct MetaCityApp: App {
    @StateObject private var session: SessionStore
    private let environment: AppEnvironment

    init() {
        // Guarded rather than unconditional: `FirebaseApp.configure()` crashes hard if
        // GoogleService-Info.plist isn't in the bundle, and that file is gitignored (see
        // .gitignore) since this repo is public. Anyone without it still gets a fully working
        // app on the in-memory mocks — see `AppEnvironment.defaultAuthRepository()`.
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        let environment = AppEnvironment()
        self.environment = environment
        _session = StateObject(wrappedValue: SessionStore(authRepository: environment.authRepository))
    }

    var body: some Scene {
        WindowGroup {
            // Passed explicitly rather than via `.environmentObject` so every screen's dependencies
            // are visible in its initializer — no hidden environment lookups to trace through.
            RootView(environment: environment, session: session)
        }
    }
}
