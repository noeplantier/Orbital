import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                header

                VStack(spacing: Spacing.md) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        .appTextFieldStyle(icon: "envelope", isFocused: focusedField == .email)
                        .accessibilityLabel("Email address")

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(viewModel.mode == .login ? .password : .newPassword)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { Task { await viewModel.submit() } }
                        .appTextFieldStyle(icon: "lock", isFocused: focusedField == .password)
                        .accessibilityLabel("Password")
                }

                PrimaryButton(
                    title: viewModel.mode.submitTitle,
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.canSubmit
                ) {
                    Task { await viewModel.submit() }
                }

                Button {
                    viewModel.toggleMode()
                } label: {
                    Text(viewModel.mode.toggleTitle)
                        .font(.orbitalSubheadline)
                        .foregroundStyle(Color.orbitalTextSecondary)
                        .frame(minHeight: 44)
                }

                demoHint
            }
            .padding(Spacing.xl)
            .animation(Motion.standard, value: viewModel.mode)
        }
        .background(Color.orbitalBackground)
        .errorAlert($viewModel.presentedError)
    }

    private var header: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.orbitalPrimary)
                .padding(.top, Spacing.xxl)
                .accessibilityHidden(true)
            Text("Orbital")
                .font(.orbitalLargeTitle)
                .foregroundStyle(Color.orbitalTextPrimary)
            Text(viewModel.mode == .login ? "Welcome back" : "Create your account")
                .font(.orbitalSubheadline)
                .foregroundStyle(Color.orbitalTextSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var demoHint: some View {
        Text("Demo account: demo@orbital.app / password123")
            .font(.orbitalCaption)
            .foregroundStyle(Color.orbitalTextTertiary)
            .padding(.top, Spacing.xs)
    }
}

#Preview {
    let authRepository = MockAuthRepository()
    AuthView(
        viewModel: AuthViewModel(
            authRepository: authRepository,
            loginUseCase: LoginUseCase(authRepository: authRepository),
            session: SessionStore(authRepository: authRepository)
        )
    )
}
