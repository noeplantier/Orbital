import SwiftUI

/// Orbital's type scale. Every token is built on a system *text style* (`.body`, `.headline`, ...)
/// rather than a fixed point size — that's what makes it scale automatically with the user's
/// Dynamic Type setting (Settings > Accessibility > Display & Text Size). The `.rounded` design on
/// the two largest styles gives the brand a slightly softer, friendlier edge without sacrificing
/// that scaling behavior, since `design:` and `weight:` layer on top of a text style, not a raw size.
extension Font {
    static let orbitalLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let orbitalTitle = Font.system(.title2, design: .rounded).weight(.semibold)
    static let orbitalTitle3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let orbitalHeadline = Font.system(.headline, design: .default)
    static let orbitalBody = Font.system(.body, design: .default)
    static let orbitalSubheadline = Font.system(.subheadline, design: .default)
    static let orbitalCaption = Font.system(.caption, design: .default)
}
