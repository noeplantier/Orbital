import SwiftUI

/// Top-level auth gate: shows `AuthView` when signed out, `HomeTabView` once a session exists.
/// Because both branches are driven by `SessionStore`, no individual feature screen needs its own auth check.
struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    let environment: AppEnvironment

    var body: some View {
        Group {
            if session.currentUser != nil {
                HomeTabView(environment: environment)
            } else {
                AuthView(viewModel: environment.makeAuthViewModel(session: session))
            }
        }
        .task {
            await session.restoreExistingSession()
        }
        .animation(.default, value: session.currentUser)
    }
}
