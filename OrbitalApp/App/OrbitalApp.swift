import SwiftUI

@main
struct OrbitalApp: App {
    @StateObject private var session: SessionStore
    private let environment: AppEnvironment

    init() {
        let environment = AppEnvironment()
        self.environment = environment
        _session = StateObject(wrappedValue: SessionStore(authRepository: environment.authRepository))
    }

    var body: some Scene {
        WindowGroup {
            RootView(environment: environment)
                .environmentObject(session)
        }
    }
}
