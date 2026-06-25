import SwiftUI

@MainActor
final class Scene3DViewModel: ObservableObject {
    @Published var rotationSpeed: Double = 1.0
    @Published var isAutoRotating = true
    @Published var cubeColorIndex = 0
    @Published var resetCameraTick = 0

    let availableColors: [Color] = [.orbitalPrimary, .orbitalSecondary, .orbitalWarning, .orbitalDanger]

    var cubeColor: Color {
        availableColors[cubeColorIndex % availableColors.count]
    }

    func cycleColor() {
        cubeColorIndex += 1
    }

    func resetCamera() {
        isAutoRotating = true
        rotationSpeed = 1.0
        resetCameraTick += 1
    }
}
