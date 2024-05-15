//
//  PSMRight.swift
//  ARPersistence
//
//  Created by Akhil Deo on 6/21/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class PSMRight: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - IBOutlet
    
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var gripperValLabel: UILabel!
    @IBOutlet weak var cameraButton: RoundedButton!
    @IBOutlet weak var clutchButton: RoundedButton!
    @IBOutlet weak var resetCameraButton: UIButton!
    var isCameraBtnPressed: Bool
    var isClutchBtnPressed: Bool
    var isCameraResetPressed: Bool
    var network: UDPClient
    var ip_address: String
    var sendTransform: String
    var stringDict: Dictionary<String, String>
    var lastValues: Dictionary<String, Float>
    var curValues: Dictionary<String, Float>
    var priorCurValues: Dictionary<String, Float>
    var gripperValue: Double
    var timer: Timer?
    var orientation: Bool = false
    
    
    @IBAction func isCameraResetBtnPressed(_ sender: Any) {
        self.isCameraResetPressed = true
    }
    
    @IBAction func isResetCameraBtnReleased(_ sender: Any) {
        self.isCameraResetPressed = false
    }
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
        self.isCameraBtnPressed = true
    }
    
    @IBAction func cameraBtnReleased(_ sender: Any) {
        self.isCameraBtnPressed = false
    }
    
    @IBAction func clutchBtnPressed(_ sender: Any) {
        self.isClutchBtnPressed = true
    }
    
    @IBAction func clutchBtnReleased(_ sender: Any) {
        self.isClutchBtnPressed = false
        clutchOffsetCalculation(lastValues, curValues)
    }
    
    @IBAction func incrementGripper(_ sender: Any) {
        singleIncreaseGripper()
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(rapidIncreaseGripper), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func stopGripper(_ sender: Any) {
        invalidateTimer()
    }
    
    @objc func rapidIncreaseGripper() {
        if (gripperValue >= 0.95) {
            gripperValue = 1.0
            invalidateTimer()
        } else {
            gripperValue += 0.05
        }
    }
    
    func singleIncreaseGripper() {
        if (gripperValue >= 0.95) {
            gripperValue = 1.0
        } else {
            gripperValue += 0.05
        }
    }
    
    func invalidateTimer() {
        timer?.invalidate()
    }
    
    
    @IBAction func decrementGripper(_ sender: Any) {
        singleDecreaseGripper()
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(rapidDecreaseGripper), userInfo: nil, repeats: true)
    }
    
    func singleDecreaseGripper() {
        if (gripperValue <= 0.05) {
            gripperValue = 0.0
        } else {
            gripperValue -= 0.05
        }
    }
    
    @objc func rapidDecreaseGripper() {
        if (gripperValue <= 0.05) {
            gripperValue = 0.0
            invalidateTimer()
        } else {
            gripperValue -= 0.05
        }
    }
    
    
    init(ip_address: String) {
        self.ip_address = MyVariables.ip_address
        self.network = MyVariables.network!
        self.isCameraBtnPressed = false
        self.isClutchBtnPressed = false
        self.isCameraResetPressed = false
        self.sendTransform = ""
        self.stringDict = ["x": "",
                           "y": "",
                           "z": "",
                           "roll": "",
                           "pitch": "",
                           "yaw": "",
                           "end_effector": "",
                           "psm": "",
                           "transformation": ""]
        self.lastValues = ["x": 0.0,
                           "y": 0.0,
                           "z": 0.0,
                           "roll": 0.0,
                           "pitch": 0.0,
                           "yaw": 0.0 ]
        self.curValues = self.lastValues
        self.priorCurValues = self.curValues
        self.gripperValue = 0.5
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.ip_address = MyVariables.ip_address
        self.network = MyVariables.network!
        self.isCameraBtnPressed = false
        self.isClutchBtnPressed = false
        self.isCameraResetPressed = false
        self.sendTransform = ""
        self.stringDict = ["x": "",
                           "y": "",
                           "z": "",
                           "roll": "",
                           "pitch": "",
                           "yaw": "",
                           "end_effector": "",
                           "psm": "",
                           "transformation": "",
                           "rotation": ""]
        self.lastValues = ["x": 0.0,
                           "y": 0.0,
                           "z": 0.0,
                           "roll": 0.0,
                           "pitch": 0.0,
                           "yaw": 0.0 ]
        self.curValues = self.lastValues
        self.priorCurValues = self.curValues
        self.gripperValue = 0.5
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Life Cycle
    
    // Lock the orientation of the app to the orientation in which it is launched
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Right PSM"
        clutchButton.setDynamicFontSize()
        cameraButton.setDynamicFontSize()
        resetCameraButton.setDynamicFontSize()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        // Start the view's AR session.
        sceneView.session.delegate = self
        sceneView.preferredFramesPerSecond = 120
        sceneView.session.run(defaultConfiguration)
        
        sceneView.debugOptions = [.showFeaturePoints]
        
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    // MARK: - transferring world (xyz rpy) values
    
    func sendTransformationRight(_ session: ARSession) {
        //updateLastValues(session)
        updateValues(session, &(self.lastValues), true, true)
        if (MyVariables.saveDaVinciOrientation && MyVariables.savePSMOrientation) {
            let currPos = simd_float3(x: lastValues["x"]!, y: lastValues["y"]!, z: lastValues["z"]!)
            let rotatedVector = MyVariables.rotationMatrix * currPos
            self.lastValues["x"] = rotatedVector[0]
            self.lastValues["y"] = rotatedVector[1]
            self.lastValues["z"] = rotatedVector[2]
            
        }
        updateStringDict()
        self.sendTransform = (stringDict["x"]! + stringDict["y"]! + stringDict["z"]! + stringDict["roll"]! + stringDict["pitch"]! + stringDict["yaw"]! + stringDict["end_effector"]! + stringDict["camera"]! + stringDict["transformation"]! + " \"test\": \"false\"," + stringDict["rotation"]! + stringDict["psm"]!)
            self.network.send(sendTransform.data(using: .utf8)!)
    }
    
    func updateStringDict() {
    
        
        self.stringDict["x"] = "{\"x\": \(String(describing: self.lastValues["x"]! + MyVariables.clutchOffset["x"]!)),"
        self.stringDict["y"] = " \"y\": \(String(describing: self.lastValues["y"]! + MyVariables.clutchOffset["y"]!)),"
        self.stringDict["z"] = " \"z\": \(String(describing: self.lastValues["z"]! + MyVariables.clutchOffset["z"]!)),"
        
        self.stringDict["roll"] = " \"roll\": \(String(describing: self.lastValues["roll"]! + MyVariables.clutchOffset["roll"]!)),"
        self.stringDict["pitch"] = " \"pitch\": \(String(describing: self.lastValues["pitch"]! + MyVariables.clutchOffset["pitch"]!)),"
        self.stringDict["yaw"] = " \"yaw\": \(String(describing: self.lastValues["yaw"]! + MyVariables.clutchOffset["yaw"]!)),"
        self.stringDict["end_effector"] = " \"end_effector\": \(String(describing: gripperValue)),"
        self.stringDict["camera"] = " \"camera\": \"false\","
        self.stringDict["transformation"] = " \"transformation\": \"true\","
        self.stringDict["rotation"] = " \"rotation\": \(String(describing: MyVariables.angle)),"
        self.stringDict["psm"] = " \"psm\": \"right\"}"
        print(stringDict)
    }
    
    func sendOrientationRight(_ session: ARSession) {
        updateValues(session, &(self.lastValues), false, true)
//        wristOutOfBounds()
//        if (inBounds()) {
            self.network.send(("{\"end_effector\":  \(String(describing: gripperValue))," + " \"camera\": \"false\"," + " \"transformation\": \"false\"," + " \"roll\": \(String(describing: self.lastValues["roll"]! + MyVariables.clutchOffset["roll"]!))," + " \"pitch\": \(String(describing: self.lastValues["pitch"]! + MyVariables.clutchOffset["pitch"]!))," + " \"yaw\": \(String(describing: self.lastValues["yaw"]! + MyVariables.clutchOffset["yaw"]!))," + " \"test\": \"false\"," + " \"rotation\": \(String(describing: MyVariables.angle))," + "\"psm\": \"right\"}").data(using: .utf8)!)
//        }
        
    }
//    func inBounds() -> Bool {
//        return self.lastValues["pitch"]! + MyVariables.clutchOffset["pitch"]! >= -1.37 && self.lastValues["pitch"]! + MyVariables.clutchOffset["pitch"]! <= 1.37 && self.lastValues["yaw"]! + MyVariables.clutchOffset["yaw"]! >= -1.37 && self.lastValues["yaw"]! + MyVariables.clutchOffset["yaw"]! <= 1.37 && (self.lastValues["roll"]! + MyVariables.clutchOffset["roll"]! - (Float.pi / 4)) >= -4.52 && (self.lastValues["roll"]! + MyVariables.clutchOffset["roll"]! - (Float.pi / 4)) <= 4.52
//    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable Save button only when the mapping status is good and an object has been placed
        switch frame.worldMappingStatus {
        case .extending, .mapped:
//            print("EXTENDING")
            if (isCameraResetPressed) {
//                print("CAMERA RESET")
                resetCamera()
                sessionInfoLabel.text = "Camera View Reset"
                sessionInfoView.isHidden = false
//            } else if (isCameraBtnPressed) {
//                priorCurValues = curValues
//                updateValues(session, &(self.curValues), true, true)
//                sendCameraTransformation(priorCurValues, curValues)
            } else {
                priorCurValues = curValues
                updateValues(session, &(self.curValues), true, true)
                if (MyVariables.saveDaVinciOrientation && MyVariables.savePSMOrientation) {
                    let angle: Double = MyVariables.DaVinciOrientation[0] - MyVariables.PSMOrientation[0]
                    let rotationMatrix = makeRotationMatrix(angle: Float(angle))
                    let currPos = simd_float3(x: curValues["x"]!, y: curValues["y"]!, z: curValues["z"]!)
                    let rotatedVector = rotationMatrix * currPos
                    self.curValues["x"] = rotatedVector[0]
                    self.curValues["y"] = rotatedVector[1]
                    self.curValues["z"] = rotatedVector[2]
                    
                }
                if (orientation == true) {
                    clutchOffsetCalculation(lastValues, curValues)
                    orientation = false
                }
                if (!isClutchBtnPressed) {
//                    if (distanceBetween(priorCurValues, curValues) < 0.01) {
                        sendTransformationRight(session)
//                    } else {
//                        clutchOffsetCalculation(priorCurValues, curValues)
//                    }
                }
            }
        case .limited:
            orientation = true
            if (isCameraResetPressed) {
//                print("CAMERA RESET")
                resetCamera()
                sessionInfoLabel.text = "Camera View Reset"
                sessionInfoView.isHidden = false
            } else if (isCameraBtnPressed) {
                priorCurValues = curValues
                updateValues(session, &(self.curValues), false, true)
                sendCameraTransformation(priorCurValues, curValues)
            } else {
                priorCurValues = curValues
                updateValues(session, &(self.curValues), false, true)
                if (!isClutchBtnPressed) {
                    //                    print(rpyChange(priorCurValues, curValues))
//                    if (rpyChange(priorCurValues, curValues) < 0.04) {
                        sendOrientationRight(session)
//                    } else {
//                        clutchOffsetCalculation(priorCurValues, curValues)
//                    }
                }
            }
        default:
            break
        }
        gripperValLabel.text = ("\(String(describing: round(gripperValue * 1000) / 10) + "%")")
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    
    // MARK: - AR session management
    
    var isRelocalizingMap = false
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        if #available(iOS 13.0, *) {
            configuration.isCollaborationEnabled = false
        }

        
        return configuration
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch (trackingState, frame.worldMappingStatus) {
        case (.normal, .mapped),
            (.normal, .extending):
            //message = "Mapped or Extending"
            message = "Transformation Transmitting"
            sessionInfoView.backgroundColor = UIColor.green
            sessionInfoLabel.textColor = UIColor.white
            
        case (.normal, _) where !isRelocalizingMap:
            message = "Only Orientation Transmitting"
            sessionInfoLabel.textColor = UIColor.black
            sessionInfoView.backgroundColor = UIColor.yellow
            
        default:
            message = trackingState.localizedFeedback
            sessionInfoView.backgroundColor = UIColor.red
            sessionInfoLabel.textColor = UIColor.white
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
}


