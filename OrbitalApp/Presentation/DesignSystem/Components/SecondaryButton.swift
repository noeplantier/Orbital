import SwiftUI

/// A quieter alternative to `PrimaryButton` for actions that shouldn't compete with the screen's
/// main CTA (e.g. "Cycle color", "Reset camera"). Outlined rather than filled, so it stays in the
/// app's neutral palette instead of adding another loud color.
struct SecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.orbitalHeadline)
            }
            .frame(minHeight: 44)
            .padding(.horizontal, Spacing.lg)
            .foregroundStyle(Color.orbitalTextPrimary)
            .background(Color.orbitalSurfaceElevated, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .strokeBorder(Color.orbitalBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityLabel(title)
    }
}

#Preview {
    SecondaryButton(title: "Reset camera", systemImage: "arrow.counterclockwise", action: {})
        .padding()
        .background(Color.orbitalBackground)
}
