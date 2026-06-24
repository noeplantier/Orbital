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
                .background(Color.black.opacity(0.05))

                controls
            }
            .navigationTitle("3D Preview")
        }
    }

    private var controls: some View {
        VStack(spacing: 16) {
            Toggle("Auto-rotate", isOn: $viewModel.isAutoRotating)
                .font(.orbitalBody)

            VStack(alignment: .leading, spacing: 6) {
                Text("Rotation speed")
                    .font(.orbitalCaption)
                    .foregroundStyle(Color.orbitalTextSecondary)
                Slider(value: $viewModel.rotationSpeed, in: 0.2...3.0)
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.cycleColor()
                } label: {
                    Label("Cycle color", systemImage: "paintpalette.fill")
                        .font(.orbitalCaption)
                }
                Spacer()
                Button {
                    viewModel.resetCamera()
                } label: {
                    Label("Reset camera", systemImage: "arrow.counterclockwise")
                        .font(.orbitalCaption)
                }
            }
            .foregroundStyle(Color.orbitalPrimary)

            Text("Drag to orbit, pinch to zoom — SceneKit's built-in camera controls. Swap makeScene() for a loaded .usdz to preview a real 3D asset.")
                .font(.orbitalCaption)
                .foregroundStyle(Color.orbitalTextSecondary)
        }
        .padding(20)
        .background(Color.orbitalSurface)
    }
}

#Preview {
    Scene3DScreenView(viewModel: Scene3DViewModel())
}
