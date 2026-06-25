import SwiftUI

struct Scene3DScreenView: View {
    @ObservedObject var viewModel: Scene3DViewModel

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
                .background(Color.orbitalBackground)
                .accessibilityLabel("3D preview of a rotating cube")
                .accessibilityHint("Drag to orbit the camera, pinch to zoom")

                controls
            }
            .background(Color.orbitalBackground)
            .navigationTitle("3D Preview")
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Toggle("Auto-rotate", isOn: $viewModel.isAutoRotating)
                .font(.orbitalBody)
                .tint(Color.orbitalPrimary)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Rotation speed")
                    .font(.orbitalCaption)
                    .foregroundStyle(Color.orbitalTextSecondary)
                Slider(value: $viewModel.rotationSpeed, in: 0.2...3.0)
                    .tint(Color.orbitalPrimary)
                    .accessibilityValue("\(Int(viewModel.rotationSpeed * 100)) percent")
            }

            HStack(spacing: Spacing.lg) {
                controlAction(title: "Cycle color", systemImage: "paintpalette.fill", action: viewModel.cycleColor)
                Spacer(minLength: 0)
                controlAction(title: "Reset camera", systemImage: "arrow.counterclockwise", action: viewModel.resetCamera)
            }

            Text("Drag to orbit, pinch to zoom — SceneKit's built-in camera controls. Swap makeScene() for a loaded .usdz to preview a real 3D asset.")
                .font(.orbitalCaption)
                .foregroundStyle(Color.orbitalTextTertiary)
        }
        .padding(Spacing.xl)
        .background(
            Color.orbitalSurface,
            in: UnevenRoundedRectangle(topLeadingRadius: Radius.card, topTrailingRadius: Radius.card, style: .continuous)
        )
        .overlay(alignment: .top) {
            Rectangle().fill(Color.orbitalSeparator).frame(height: 1)
        }
    }

    private func controlAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.orbitalSubheadline)
                .frame(minHeight: 44)
        }
        .foregroundStyle(Color.orbitalPrimary)
    }
}

#Preview {
    Scene3DScreenView(viewModel: Scene3DViewModel())
}
