import SwiftUI

/// A circular initials avatar, used for the signed-in user and call participants. Replaces the ad-hoc
/// `Image(systemName: "person.crop.circle.fill")` placeholders with something that actually carries
/// identity — initials read faster than a generic person glyph, and it's free of any network/asset
/// dependency, which matters while there's no real backend yet.
struct Avatar: View {
    let name: String
    var size: CGFloat = 44

    var body: some View {
        Circle()
            .fill(Color.orbitalSurfaceElevated)
            .overlay(Circle().strokeBorder(Color.orbitalBorder, lineWidth: 1))
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.orbitalTextPrimary)
            )
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }
}

#Preview {
    HStack {
        Avatar(name: "Demo User")
        Avatar(name: "Teammate 1", size: 32)
    }
    .padding()
    .background(Color.orbitalBackground)
}
