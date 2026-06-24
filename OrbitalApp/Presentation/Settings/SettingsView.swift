import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var isLoggingOut = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.orbitalPrimary)
                        VStack(alignment: .leading) {
                            Text(viewModel.currentUser?.displayName ?? "Guest")
                                .font(.orbitalHeadline)
                            Text(viewModel.currentUser?.email ?? "")
                                .font(.orbitalCaption)
                                .foregroundStyle(Color.orbitalTextSecondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Coming soon") {
                    // Extension points: each of these is added by introducing a new Domain protocol
                    // + Data implementation + ViewModel, the same pattern as Auth/Map/Call.
                    ComingSoonRow(systemImage: "bell.badge.fill", title: "Push notifications")
                    ComingSoonRow(systemImage: "chart.bar.fill", title: "Analytics")
                    ComingSoonRow(systemImage: "icloud.fill", title: "Real backend (Firebase/Auth0)")
                }

                Section {
                    PrimaryButton(title: "Log Out", isLoading: isLoggingOut) {
                        Task {
                            isLoggingOut = true
                            await viewModel.logout()
                            isLoggingOut = false
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Profile")
            .errorAlert($viewModel.presentedError)
        }
    }
}

private struct ComingSoonRow: View {
    let systemImage: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundStyle(Color.orbitalTextSecondary)
                .frame(width: 28)
            Text(title)
                .font(.orbitalBody)
            Spacer()
            Text("Soon")
                .font(.orbitalCaption)
                .foregroundStyle(Color.orbitalTextSecondary)
        }
    }
}

#Preview {
    let authRepository = MockAuthRepository()
    SettingsView(viewModel: SettingsViewModel(authRepository: authRepository, session: SessionStore(authRepository: authRepository)))
}
