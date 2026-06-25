import SwiftUI

struct LandmarkInspectorView: View {
    @ObservedObject var viewModel: LandmarkInspectorViewModel
    /// Set when opened from Explore for a specific place; falls back to a generic title when
    /// opened standalone (e.g. from a future dedicated "3D" entry point).
    var landmarkTitle: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                RotatingCubeSceneView(
                    rotationSpeed: viewModel.rotationSpeed,
                    isAutoRotating: viewModel.isAutoRotating,
                    cubeColor: viewModel.cubeColor,
                    resetCameraTick: viewModel.resetCameraTick
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.metacityBackground)
                .accessibilityLabel("3D preview of \(landmarkTitle ?? "a rotating cube")")
                .accessibilityHint("Drag to orbit the camera, pinch to zoom")

                controls
            }
            .background(Color.metacityBackground)
            .navigationTitle(landmarkTitle ?? "3D Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Toggle("Auto-rotate", isOn: $viewModel.isAutoRotating)
                .font(.metacityBody)
                .tint(Color.metacityPrimary)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Rotation speed")
                    .font(.metacityCaption)
                    .foregroundStyle(Color.metacityTextSecondary)
                Slider(value: $viewModel.rotationSpeed, in: 0.2...3.0)
                    .tint(Color.metacityPrimary)
                    .accessibilityValue("\(Int(viewModel.rotationSpeed * 100)) percent")
            }

            HStack(spacing: Spacing.lg) {
                controlAction(title: "Cycle color", systemImage: "paintpalette.fill", action: viewModel.cycleColor)
                Spacer(minLength: 0)
                controlAction(title: "Reset camera", systemImage: "arrow.counterclockwise", action: viewModel.resetCamera)
            }

            Text("Drag to orbit, pinch to zoom — SceneKit's built-in camera controls. Swap makeScene() for a loaded .usdz to preview a real 3D asset.")
                .font(.metacityCaption)
                .foregroundStyle(Color.metacityTextTertiary)
        }
        .padding(Spacing.xl)
        .background(
            Color.metacitySurface,
            in: UnevenRoundedRectangle(topLeadingRadius: Radius.card, topTrailingRadius: Radius.card, style: .continuous)
        )
        .overlay(alignment: .top) {
            Rectangle().fill(Color.metacitySeparator).frame(height: 1)
        }
    }

    private func controlAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.metacitySubheadline)
                .frame(minHeight: 44)
        }
        .foregroundStyle(Color.metacityPrimary)
    }
}

#Preview {
    LandmarkInspectorView(viewModel: LandmarkInspectorViewModel())
}
