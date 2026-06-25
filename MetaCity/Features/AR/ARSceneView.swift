import ARKit
import SceneKit
import SwiftUI

/// Thin UIViewRepresentable bridge to ARKit + SceneKit, mirroring the same wrapper pattern as
/// `RotatingCubeSceneView`. This is real, runnable ARKit code — not a placeholder — but world
/// tracking needs a camera, so it only actually does anything on a physical device; the Simulator
/// has no camera to track against (see `ARViewModel.isARSupported`, checked before this is shown).
struct ARSceneView: UIViewRepresentable {
    @Binding var placedMarkerCount: Int

    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView()
        view.autoenablesDefaultLighting = true
        view.automaticallyUpdatesLighting = true

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        view.session.run(configuration)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        context.coordinator.arView = view

        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(placedMarkerCount: $placedMarkerCount)
    }

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        uiView.session.pause()
    }

    final class Coordinator: NSObject {
        @Binding var placedMarkerCount: Int
        weak var arView: ARSCNView?

        init(placedMarkerCount: Binding<Int>) {
            self._placedMarkerCount = placedMarkerCount
        }

        /// Real implementation: this is where AR city markers / POI labels get anchored to the
        /// real world. Raycasting against the detected plane is the standard ARKit pattern for
        /// "place an object where the user tapped".
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView,
                  let query = arView.raycastQuery(from: gesture.location(in: arView), allowing: .estimatedPlane, alignment: .horizontal),
                  let result = arView.session.raycast(query).first else {
                return
            }

            let markerNode = SCNNode(geometry: SCNSphere(radius: 0.04))
            markerNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
            markerNode.simdTransform = result.worldTransform
            arView.scene.rootNode.addChildNode(markerNode)
            placedMarkerCount += 1
        }
    }
}
