import SwiftUI

@main
struct MetaCityApp: App {
    @StateObject private var session: SessionStore
    private let environment: AppEnvironment

    init() {
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
