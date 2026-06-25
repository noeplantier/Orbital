import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isLoggingOut = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    profileRow
                }
                .listRowBackground(Color.metacitySurface)

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
                .listRowBackground(Color.metacitySurface)

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
            .background(Color.metacityBackground)
            .navigationTitle("Profile")
            .errorAlert($viewModel.presentedError)
        }
    }

    private var profileRow: some View {
        HStack(spacing: Spacing.md) {
            Avatar(name: viewModel.currentUser?.displayName ?? "Guest", size: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentUser?.displayName ?? "Guest")
                    .font(.metacityHeadline)
                    .foregroundStyle(Color.metacityTextPrimary)
                Text(viewModel.currentUser?.email ?? "")
                    .font(.metacitySubheadline)
                    .foregroundStyle(Color.metacityTextSecondary)
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
                .foregroundStyle(Color.metacityTextSecondary)
                .frame(width: 28)
            Text(title)
                .font(.metacityBody)
                .foregroundStyle(Color.metacityTextPrimary)
            Spacer()
            Text("Soon")
                .font(.metacityCaption)
                .foregroundStyle(Color.metacityTextTertiary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let authRepository = MockAuthRepository()
    ProfileView(viewModel: ProfileViewModel(authRepository: authRepository, session: SessionStore(authRepository: authRepository)))
}
