import SwiftUI

/// Reusable call-to-action button used across every feature (Auth submit, call controls, etc.)
/// so button styling only ever needs to change in one place.
struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.orbitalHeadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isEnabled ? Color.orbitalPrimary : Color.orbitalPrimary.opacity(0.4))
            )
        }
        .disabled(!isEnabled || isLoading)
        .animation(.easeOut(duration: 0.15), value: isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue", action: {})
        PrimaryButton(title: "Joining…", isLoading: true, action: {})
        PrimaryButton(title: "Disabled", isEnabled: false, action: {})
    }
    .padding()
}
