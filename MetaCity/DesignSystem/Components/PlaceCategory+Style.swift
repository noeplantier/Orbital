import SwiftUI

/// Presentation-only styling for `PlaceCategory`, kept out of `Models` so that layer stays
/// framework-agnostic. Both the Map markers and Explore's landmark rows share this mapping —
/// previously duplicated in each view, now defined once.
extension PlaceCategory {
    var systemImage: String {
        switch self {
        case .office: return "building.2.fill"
        case .partner: return "person.2.fill"
        case .pointOfInterest: return "star.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .office: return .metacityPrimary
        case .partner: return .metacitySecondary
        case .pointOfInterest: return .metacityWarning
        }
    }
}
