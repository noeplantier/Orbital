import SceneKit
import SwiftUI

/// UIViewRepresentable bridge between SceneKit's UIKit-based `SCNView` and SwiftUI. Keeping this
/// wrapper thin (geometry/lighting/camera setup only) means swapping in a loaded USDZ asset later
/// is a one-function change — see `makeScene()`.
struct RotatingCubeSceneView: UIViewRepresentable {
    var rotationSpeed: Double
    var isAutoRotating: Bool
    var cubeColor: Color
    var resetCameraTick: Int

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = makeScene()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.allowsCameraControl = true // drag to orbit, pinch to zoom — "basic camera controls"
        return view
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let cubeNode = scnView.scene?.rootNode.childNode(withName: "metacityCube", recursively: true) else { return }
        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(cubeColor)

        cubeNode.removeAction(forKey: "spin")
        if isAutoRotating {
            addSpinAction(to: cubeNode)
        }

        if context.coordinator.lastResetTick != resetCameraTick,
           let cameraNode = scnView.scene?.rootNode.childNode(withName: "metacityCamera", recursively: true) {
            context.coordinator.lastResetTick = resetCameraTick
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.4
            cameraNode.position = SCNVector3(x: 0, y: 0.6, z: 4)
            cameraNode.rotation = SCNVector4(0, 0, 1, 0)
            SCNTransaction.commit()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var lastResetTick = 0
    }

    private func makeScene() -> SCNScene {
        // Production note: to show a real asset instead of a primitive, replace this method body
        // with `SCNScene(named: "Model.scnassets/Asset.usdz")` — camera, lighting, and the rotation
        // action below keep working unchanged. Keep USDZ files under ~10-15MB and textures at 2K or
        // less for smooth mobile performance; both SceneKit and RealityKit support compressed textures.
        let scene = SCNScene()

        let cubeGeometry = SCNBox(width: 1.4, height: 1.4, length: 1.4, chamferRadius: 0.12)
        cubeGeometry.firstMaterial?.diffuse.contents = UIColor(cubeColor)
        cubeGeometry.firstMaterial?.specular.contents = UIColor.white
        cubeGeometry.firstMaterial?.metalness.contents = 0.3
        cubeGeometry.firstMaterial?.roughness.contents = 0.4

        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.name = "metacityCube"
        scene.rootNode.addChildNode(cubeNode)
        addSpinAction(to: cubeNode)

        let cameraNode = SCNNode()
        cameraNode.name = "metacityCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0.6, z: 4)
        scene.rootNode.addChildNode(cameraNode)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.intensity = 900
        keyLight.position = SCNVector3(x: 3, y: 5, z: 4)
        keyLight.look(at: cubeNode.position)
        scene.rootNode.addChildNode(keyLight)

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 300
        scene.rootNode.addChildNode(ambientLight)

        return scene
    }

    private func addSpinAction(to node: SCNNode) {
        let spin = SCNAction.rotateBy(x: 0, y: CGFloat(rotationSpeed), z: 0, duration: 1)
        node.runAction(.repeatForever(spin), forKey: "spin")
    }
}
