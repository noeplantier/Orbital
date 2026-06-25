import SwiftUI

/// Single place where every feature tab is assembled and wired to its dependencies — adding a new
/// tab means adding one `@StateObject` here and one `make...ViewModel()` in `AppEnvironment`.
///
/// Every ViewModel is created once via `@StateObject` in `init`, not inline as `@ObservedObject`
/// arguments — see the note in `RootView` for why that distinction matters (it's what keeps the map
/// camera, the in-call state, etc. from resetting whenever this view's body re-evaluates).
struct HomeTabView: View {
    @ObservedObject private var session: SessionStore
    @StateObject private var exploreViewModel: ExploreViewModel
    @StateObject private var mapViewModel: MapViewModel
    @StateObject private var arViewModel: ARViewModel
    @StateObject private var callViewModel: CallViewModel
    @StateObject private var profileViewModel: ProfileViewModel

    init(environment: AppEnvironment, session: SessionStore) {
        self.session = session
        _exploreViewModel = StateObject(wrappedValue: environment.makeExploreViewModel(session: session))
        _mapViewModel = StateObject(wrappedValue: environment.makeMapViewModel())
        _arViewModel = StateObject(wrappedValue: environment.makeARViewModel())
        _callViewModel = StateObject(wrappedValue: environment.makeCallViewModel())
        _profileViewModel = StateObject(wrappedValue: environment.makeProfileViewModel(session: session))
    }

    var body: some View {
        TabView {
            ExploreScreenView(viewModel: exploreViewModel)
                .tabItem { Label("Explore", systemImage: "safari.fill") }

            MapScreenView(viewModel: mapViewModel)
                .tabItem { Label("Map", systemImage: "map.fill") }

            ARScreenView(viewModel: arViewModel)
                .tabItem { Label("AR", systemImage: "arkit") }

            CallLobbyView(viewModel: callViewModel)
                .tabItem { Label("Calls", systemImage: "phone.fill") }

            ProfileView(viewModel: profileViewModel)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.metacityPrimary)
    }
}

#Preview {
    let environment = AppEnvironment()
    HomeTabView(environment: environment, session: SessionStore(authRepository: MockAuthRepository()))
}
