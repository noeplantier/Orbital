import SwiftUI

/// Single place where every feature tab is assembled and wired to its dependencies — adding a new
/// tab (e.g. "Notifications") means adding one case here and one `make...ViewModel()` in AppEnvironment.
struct HomeTabView: View {
    let environment: AppEnvironment
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        TabView {
            MapScreenView(viewModel: environment.makeMapViewModel())
                .tabItem { Label("Map", systemImage: "map.fill") }

            Scene3DScreenView(viewModel: environment.makeScene3DViewModel())
                .tabItem { Label("3D", systemImage: "cube.fill") }

            CallLobbyView(viewModel: environment.makeCallViewModel())
                .tabItem { Label("Calls", systemImage: "phone.fill") }

            SettingsView(viewModel: environment.makeSettingsViewModel(session: session))
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.orbitalPrimary)
    }
}

#Preview {
    HomeTabView(environment: AppEnvironment())
        .environmentObject(SessionStore(authRepository: MockAuthRepository()))
}
