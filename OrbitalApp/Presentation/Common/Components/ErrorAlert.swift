import SwiftUI

/// Wraps any Error so it can drive SwiftUI's `.alert(item:)`, which requires Identifiable.
/// ViewModels expose `@Published var presentedError: IdentifiableError?` and views attach `.errorAlert(...)`.
struct IdentifiableError: Identifiable {
    let id = UUID()
    let underlyingError: Error

    var message: String {
        (underlyingError as? LocalizedError)?.errorDescription ?? underlyingError.localizedDescription
    }
}

extension View {
    /// Presents a blocking alert for errors that need explicit acknowledgement (e.g. failed login).
    /// For non-blocking, transient notices, prefer `.snackbar(...)` instead.
    func errorAlert(_ error: Binding<IdentifiableError?>) -> some View {
        alert(
            "Something went wrong",
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { isPresented in if !isPresented { error.wrappedValue = nil } }
            ),
            presenting: error.wrappedValue
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { presentedError in
            Text(presentedError.message)
        }
    }
}
