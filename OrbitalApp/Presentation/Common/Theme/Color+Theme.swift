import SwiftUI

/// Central brand palette. Defining colors as static members (rather than scattering literal values
/// across views) means a future rebrand or dark-mode tweak happens in one file.
extension Color {
    static let orbitalPrimary = Color(red: 0.25, green: 0.35, blue: 0.83)
    static let orbitalSecondary = Color(red: 0.25, green: 0.83, blue: 0.69)
    static let orbitalBackground = Color(uiColor: .systemBackground)
    static let orbitalSurface = Color(uiColor: .secondarySystemBackground)
    static let orbitalTextPrimary = Color(uiColor: .label)
    static let orbitalTextSecondary = Color(uiColor: .secondaryLabel)
    static let orbitalSuccess = Color(red: 0.20, green: 0.70, blue: 0.40)
    static let orbitalDanger = Color(red: 0.86, green: 0.23, blue: 0.23)
    static let orbitalWarning = Color(red: 0.93, green: 0.62, blue: 0.13)
}
