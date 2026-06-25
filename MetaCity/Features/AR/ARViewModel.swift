import ARKit
import Foundation

@MainActor
final class ARViewModel: ObservableObject {
    @Published var placedMarkerCount = 0

    /// `ARWorldTrackingConfiguration.isSupported` is false in the Simulator (no camera) and on a
    /// handful of older devices. Checking this up front means the screen can show a clear, honest
    /// message instead of silently starting a session that will never track anything.
    var isARSupported: Bool {
        ARWorldTrackingConfiguration.isSupported
    }
}
