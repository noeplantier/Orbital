import SwiftUI

/// Single place where every feature tab is assembled and wired to its dependencies — adding a new
/// tab (e.g. "Notifications") means adding one `@StateObject` here and one `make...ViewModel()` in
/// `AppEnvironment`.
///
/// Every ViewModel is created once via `@StateObject` in `init`, not inline as `@ObservedObject`
/// arguments — see the note in `RootView` for why that distinction matters (it's what keeps the map
/// camera, the in-call state, etc. from resetting whenever this view's body re-evaluates).
struct HomeTabView: View {
    @ObservedObject private var session: SessionStore
    @StateObject private var mapViewModel: MapViewModel
    @StateObject private var scene3DViewModel: Scene3DViewModel
    @StateObject private var callViewModel: CallViewModel
    @StateObject private var settingsViewModel: SettingsViewModel

    init(environment: AppEnvironment, session: SessionStore) {
        self.session = session
        _mapViewModel = StateObject(wrappedValue: environment.makeMapViewModel())
        _scene3DViewModel = StateObject(wrappedValue: environment.makeScene3DViewModel())
        _callViewModel = StateObject(wrappedValue: environment.makeCallViewModel())
        _settingsViewModel = StateObject(wrappedValue: environment.makeSettingsViewModel(session: session))
    }

    var body: some View {
        TabView {
            MapScreenView(viewModel: mapViewModel)
                .tabItem { Label("Map", systemImage: "map.fill") }

            Scene3DScreenView(viewModel: scene3DViewModel)
                .tabItem { Label("3D", systemImage: "cube.fill") }

            CallLobbyView(viewModel: callViewModel)
                .tabItem { Label("Calls", systemImage: "phone.fill") }

            SettingsView(viewModel: settingsViewModel)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.orbitalPrimary)
    }
}

#Preview {
    let environment = AppEnvironment()
    HomeTabView(environment: environment, session: SessionStore(authRepository: MockAuthRepository()))
}
