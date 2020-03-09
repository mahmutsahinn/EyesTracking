//
//  ViewController.swift
//  BIL496
//
//  Created by Mahmut  Şahin on 6.03.2019.
//  Copyright © 2019 Mahmut  Şahin. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var viewGameOver: UIView!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var noFaceView: UIView!
    @IBOutlet weak var lookAtPositionXLabel: UILabel!
    @IBOutlet weak var lookAtPositionYLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var sceneGame: SpaceScene?
    var faceNode: SCNNode = SCNNode()
    var eyeLNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var eyeRNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var lookAtTargetEyeLNode: SCNNode = SCNNode()
    var lookAtTargetEyeRNode: SCNNode = SCNNode()
    
    let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
    let phoneScreenPointSize = CGSize(width: 375, height: 812)
    
    var virtualPhoneNode: SCNNode = SCNNode()
    var virtualScreenNode: SCNNode = {
        let screenGeometry = SCNPlane(width: 1, height: 1)
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
        return SCNNode(geometry: screenGeometry)
    }()
    
    var eyeLookAtPositionXs: [CGFloat] = []
    var eyeLookAtPositionYs: [CGFloat] = []
    
    var timer: Timer?
    var count = 0.0
    var successTreshold: CGFloat = 0.7
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    
    private lazy var gameView = SKView()

    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.faceControl), userInfo: nil, repeats: true)
        bottomView.layer.cornerRadius = 36
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        startGame()
    }
    
    func startGame() {
        sceneGame = SpaceGame().makeScene(self)
        view.addSubview(gameView)
        sceneView.layer.cornerRadius = 28
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLNode)
        faceNode.addChildNode(eyeRNode)
        eyeLNode.addChildNode(lookAtTargetEyeLNode)
        eyeRNode.addChildNode(lookAtTargetEyeRNode)
        // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
        lookAtTargetEyeLNode.position.z = 2
        lookAtTargetEyeRNode.position.z = 2
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = view.bounds
        gameView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height - 140)
        if gameView.scene == nil {
            gameView.presentScene(sceneGame)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        update(withFaceAnchor: faceAnchor)
    }
    
    // MARK: - update(ARFaceAnchor)
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        
        eyeRNode.simdTransform = anchor.rightEyeTransform
        eyeLNode.simdTransform = anchor.leftEyeTransform
        
        var eyeLLookAt = CGPoint()
        var eyeRLookAt = CGPoint()
        
        let heightCompensation: CGFloat = 312
        
        DispatchQueue.main.async {
            let phoneScreenEyeRHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)
            let phoneScreenEyeLHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)
            for result in phoneScreenEyeRHitTestResults {
                eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                eyeRLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
            }
            for result in phoneScreenEyeLHitTestResults {
                eyeLLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                eyeLLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
            }
            let smoothThresholdNumber: Int = 10
            self.eyeLookAtPositionXs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
            self.eyeLookAtPositionYs.append(-(eyeRLookAt.y + eyeLLookAt.y) / 2)
            self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
            self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))
            let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.average!
            let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.average!
            self.sceneGame?.eyeCoordinate(smoothEyeLookAtPositionX,smoothEyeLookAtPositionY)
            self.lookAtPositionXLabel.text = "x: \(Int(round(smoothEyeLookAtPositionX + self.phoneScreenPointSize.width / 2)))"
            self.lookAtPositionYLabel.text = "y: \(Int(round(smoothEyeLookAtPositionY + self.phoneScreenPointSize.height / 2)))"
            let distanceL = self.eyeLNode.worldPosition - SCNVector3Zero
            let distanceR = self.eyeRNode.worldPosition - SCNVector3Zero
            let distance = (distanceL.length() + distanceR.length()) / 2
            self.distanceLabel.text = "distance is: \(Int(round(distance * 100))) cm"
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        update(withFaceAnchor: faceAnchor)
        detectSmile(faceAnchor)
        count = 0.0
    }
    
    private func detectSmile(_ faceAnchor: ARFaceAnchor) {
        let blendShapes = faceAnchor.blendShapes
        if let left = blendShapes[.mouthSmileLeft], let right = blendShapes[.mouthSmileRight] {
            let smileParameter = min(max(CGFloat(truncating: left), CGFloat(truncating: right))/successTreshold, 1.0)
            DispatchQueue.main.async {
                if smileParameter == 1 {
                    if self.gameView.isHidden {
                        UIView.animate(withDuration: 0.5, animations: {
                        }, completion: { _ in
                            self.newGame()
                        })
                    }
                }
            }
        }
    }
    
    @objc func faceControl() {
        count += 0.5
        if count > 0.5 {
            noFaceView.isHidden = false
            if viewGameOver.isHidden {
                gameView.isHidden = true
                sceneGame?.stopGame()
            }
        } else {
            noFaceView.isHidden = true
            if viewGameOver.isHidden {
                if gameView.isHidden {
                    sceneGame?.startGame()
                }
                gameView.isHidden = false
            }
        }
    }
    
    private func newGame() {
        viewGameOver.isHidden = true
        gameView.isHidden = false
        sceneGame?.startGame()
    }
    
    @IBAction func endGameButtonTapped(_ sender: Any) {
        addGameOver()
    }
    
}

extension ViewController: SpaceSceneDelegate {
    func addGameOver() {
        if !gameView.isHidden {
            gameView.isHidden = true
            viewGameOver.isHidden = false
            labelScore.text = "Your score is : \(sceneGame?.score ?? 0)"
        }
    }    
}
