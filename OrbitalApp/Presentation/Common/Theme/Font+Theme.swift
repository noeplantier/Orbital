import SwiftUI

/// Type scale for the app. Using semantic names (`.orbitalTitle`) instead of raw `.system(size:)`
/// calls in views keeps typography consistent and makes a future scale change a one-file edit.
extension Font {
    static let orbitalLargeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let orbitalTitle = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let orbitalHeadline = Font.system(size: 17, weight: .semibold, design: .default)
    static let orbitalBody = Font.system(size: 16, weight: .regular, design: .default)
    static let orbitalCaption = Font.system(size: 13, weight: .regular, design: .default)
}
