import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var isLoggingOut = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    profileRow
                }
                .listRowBackground(Color.orbitalSurface)

                Section {
                    ComingSoonRow(systemImage: "bell.badge.fill", title: "Push notifications")
                    ComingSoonRow(systemImage: "chart.bar.fill", title: "Analytics")
                    ComingSoonRow(systemImage: "icloud.fill", title: "Real backend (Firebase/Auth0)")
                } header: {
                    // Extension points: each of these is added by introducing a new Domain protocol
                    // + Data implementation + ViewModel, the same pattern as Auth/Map/Call.
                    SectionHeader(title: "Coming soon")
                }
                .textCase(nil)
                .listRowBackground(Color.orbitalSurface)

                Section {
                    PrimaryButton(title: "Log Out", isLoading: isLoggingOut) {
                        Task {
                            isLoggingOut = true
                            await viewModel.logout()
                            isLoggingOut = false
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.orbitalBackground)
            .navigationTitle("Profile")
            .errorAlert($viewModel.presentedError)
        }
    }

    private var profileRow: some View {
        HStack(spacing: Spacing.md) {
            Avatar(name: viewModel.currentUser?.displayName ?? "Guest", size: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentUser?.displayName ?? "Guest")
                    .font(.orbitalHeadline)
                    .foregroundStyle(Color.orbitalTextPrimary)
                Text(viewModel.currentUser?.email ?? "")
                    .font(.orbitalSubheadline)
                    .foregroundStyle(Color.orbitalTextSecondary)
            }
        }
        .padding(.vertical, Spacing.xs)
        .accessibilityElement(children: .combine)
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
                .foregroundStyle(Color.orbitalTextPrimary)
            Spacer()
            Text("Soon")
                .font(.orbitalCaption)
                .foregroundStyle(Color.orbitalTextTertiary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let authRepository = MockAuthRepository()
    SettingsView(viewModel: SettingsViewModel(authRepository: authRepository, session: SessionStore(authRepository: authRepository)))
}
