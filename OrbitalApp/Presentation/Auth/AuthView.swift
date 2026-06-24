import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                VStack(spacing: 14) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.orbitalSurface))

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(viewModel.mode == .login ? .password : .newPassword)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { Task { await viewModel.submit() } }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.orbitalSurface))
                }

                PrimaryButton(
                    title: viewModel.mode.submitTitle,
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.canSubmit
                ) {
                    Task { await viewModel.submit() }
                }

                Button(viewModel.mode.toggleTitle) {
                    viewModel.toggleMode()
                }
                .font(.orbitalCaption)
                .foregroundStyle(Color.orbitalTextSecondary)

                demoHint
            }
            .padding(24)
        }
        .background(Color.orbitalBackground)
        .errorAlert($viewModel.presentedError)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.orbitalPrimary)
                .padding(.top, 40)
            Text("Orbital")
                .font(.orbitalLargeTitle)
            Text(viewModel.mode == .login ? "Welcome back" : "Create your account")
                .font(.orbitalBody)
                .foregroundStyle(Color.orbitalTextSecondary)
        }
    }

    private var demoHint: some View {
        Text("Demo account: demo@orbital.app / password123")
            .font(.orbitalCaption)
            .foregroundStyle(Color.orbitalTextSecondary)
            .padding(.top, 8)
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
