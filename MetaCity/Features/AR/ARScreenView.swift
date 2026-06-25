import SwiftUI

struct ARScreenView: View {
    @ObservedObject var viewModel: ARViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isARSupported {
                    ZStack(alignment: .bottom) {
                        ARSceneView(placedMarkerCount: $viewModel.placedMarkerCount)
                            .ignoresSafeArea()

                        statusBanner
                    }
                } else {
                    EmptyStateView(
                        systemImage: "arkit",
                        title: "AR needs a real device",
                        message: "The Simulator has no camera, so world tracking can't run here. Build to a physical iPhone to place markers in AR."
                    )
                    .background(Color.metacityBackground)
                }
            }
            .navigationTitle("AR")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var statusBanner: some View {
        Text(viewModel.placedMarkerCount == 0 ? "Tap a surface to place a marker" : "\(viewModel.placedMarkerCount) marker(s) placed")
            .font(.metacitySubheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(.black.opacity(0.5), in: Capsule())
            .padding(.bottom, Spacing.xxl)
            .accessibilityElement(children: .combine)
    }
}

#Preview {
    ARScreenView(viewModel: ARViewModel())
}
