//
//  PSMLeft.swift
//  ARPersistence
//
//  Created by Akhil Deo on 6/21/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class PSMLeft: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - IBOutlets
    
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var gripperValLabel: UILabel!
    
    var isClutchBtnPressed: Bool
    var network: UDPClient
    var ip_address: String
    var sendTransform: String
    var stringDict: Dictionary<String, String>
    var lastValues: Dictionary<String, Float>
    var curValues: Dictionary<String, Float>
    var gripperVal: Double
    var timer: Timer?
    var orientation: Bool = false
    @IBOutlet weak var cButton: RoundedButton!
    
    
    @IBAction func clutchBtnPressed(_ sender: Any) {
        self.isClutchBtnPressed = true
        
    }
    
    @IBAction func clutchBtnReleased(_ sender: Any) {
        self.isClutchBtnPressed = false
        clutchOffsetCalculation(lastValues, curValues)
    }
    
    func invalidateTimer() {
        timer?.invalidate()
    }
    
    @IBAction func stopGripper(_ sender: Any) {
        invalidateTimer()
    }
    
    func singleIncreaseGripper() {
        if (gripperVal >= 0.95) {
            gripperVal = 1.0
        } else {
            gripperVal += 0.05
        }
    }
    
    func singleDecreaseGripper() {
        if (gripperVal <= 0.05) {
            gripperVal = 0
        } else {
            gripperVal -= 0.05
        }
    }
    
    @objc func rapidIncreaseGripper() {
        if (gripperVal >= 0.95) {
            gripperVal = 1.0
            invalidateTimer()
        } else {
            gripperVal += 0.05
        }
    }
    
    @objc func rapidDecreaseGripper() {
        if (gripperVal <= 0.05) {
            gripperVal = 0.0
            invalidateTimer()
        } else {
            gripperVal -= 0.05
        }
    }
    
    @IBAction func incrementGripper(_ sender: Any) {
        singleIncreaseGripper()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(rapidIncreaseGripper), userInfo: nil, repeats: true)
    }
    
    @IBAction func decrementGripper(_ sender: Any) {
        singleDecreaseGripper()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(rapidDecreaseGripper), userInfo: nil, repeats: true)
        
    }
    
    
    init(ip_address: String) {
        self.ip_address = MyVariables.ip_address
        self.network = MyVariables.network!
        self.isClutchBtnPressed = false
        self.sendTransform = ""
        self.stringDict = ["x": "",
                           "y": "",
                           "z": "",
                           "roll": "",
                           "pitch": "",
                           "yaw": "",
                           "slider": "",
                           "arm": "",
                           "transformation": ""]
        self.lastValues = ["x": 0.0,
                           "y": 0.0,
                           "z": 0.0,
                           "roll": 0.0,
                           "pitch": 0.0,
                           "yaw": 0.0 ]
        self.curValues = self.lastValues
        gripperVal = 0.5
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.ip_address = MyVariables.ip_address
        self.network = MyVariables.network!
        self.isClutchBtnPressed = false
        self.sendTransform = ""
        self.stringDict = ["x": "",
                           "y": "",
                           "z": "",
                           "roll": "",
                           "pitch": "",
                           "yaw": "",
                           "slider": "",
                           "arm": "",
                           "transformation": ""]
        self.lastValues = ["x": 0.0,
                           "y": 0.0,
                           "z": 0.0,
                           "roll": 0.0,
                           "pitch": 0.0,
                           "yaw": 0.0 ]
        self.curValues = self.lastValues
        gripperVal = 0.5
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Life Cycle
    
    
    // Lock the orientation of the app to the orientation in which it is launched
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hack to wait until everything is set up
        title = "Left PSM"
        cButton.setDynamicFontSize()
        
        
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
        sceneView.session.run(defaultConfiguration)
        
        sceneView.debugOptions = [ .showFeaturePoints ]
        
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    // MARK: - transferring/printing world (xyz rpm) values
    
    //Only for debugging
    func printTransformationLeft(_ session: ARSession) {
        let currentTransform = session.currentFrame?.camera.transform
        let x = currentTransform!.columns.3.x
        let y = currentTransform!.columns.3.y
        let z = currentTransform!.columns.3.z
        print("x: \(String(describing: x))")
        print("y: \(String(describing: y))")
        print("z: \(String(describing: z))")
        let currentAngles = session.currentFrame?.camera.eulerAngles
        let pitch = currentAngles!.x
        let yaw = currentAngles!.y
        let roll = currentAngles!.z
        print("roll: \(String(describing: roll))")
        print("pitch: \(String(describing: pitch))")
        print("yaw: \(String(describing: yaw))")
    }
    
    func sendTransformationLeft(_ session: ARSession) {
        //updateLastValues(session)
        updateValues(session, &(self.lastValues), true, false)
        updateStringDict()
        self.sendTransform = (stringDict["x"]! + stringDict["y"]! + stringDict["z"]! + stringDict["roll"]! + stringDict["pitch"]! + stringDict["yaw"]! + stringDict["slider"]! + stringDict["camera"]! + stringDict["transformation"]! + " \"test\": \"false\"," + stringDict["arm"]!)
        self.network.send(sendTransform.data(using: .utf8)!)
    }
    
    func updateStringDict() {
        self.stringDict["x"] = "{\"x\": \(String(describing: self.lastValues["x"]! + MyVariables.clutchOffset["x"]!)),"
        self.stringDict["y"] = " \"y\": \(String(describing: self.lastValues["y"]! + MyVariables.clutchOffset["y"]!)),"
        self.stringDict["z"] = " \"z\": \(String(describing: self.lastValues["z"]! + MyVariables.clutchOffset["z"]!)),"
        self.stringDict["roll"] = " \"roll\": \(String(describing: self.lastValues["roll"]! + MyVariables.clutchOffset["roll"]!)),"
        self.stringDict["pitch"] = " \"pitch\": \(String(describing: self.lastValues["pitch"]! + MyVariables.clutchOffset["pitch"]!)),"
        self.stringDict["yaw"] = " \"yaw\": \(String(describing: self.lastValues["yaw"]! + MyVariables.clutchOffset["yaw"]!)),"
        self.stringDict["slider"] = " \"slider\": \(String(describing: gripperVal)),"
        self.stringDict["camera"] = " \"camera\": \"false\","
        self.stringDict["transformation"] = " \"transformation\": \"true\","
        self.stringDict["arm"] = " \"arm\": \"left\"}"
    }
    
    func sendOrientationLeft(_ session: ARSession) {
        updateValues(session, &(self.lastValues), false, false)
        self.network.send(("{\"slider\":  \(String(describing: gripperVal))," + " \"camera\": \"false\"," + " \"transformation\": \"false\"," + " \"roll\": \(String(describing: self.lastValues["roll"]! + MyVariables.clutchOffset["roll"]!))," + " \"pitch\": \(String(describing: self.lastValues["pitch"]! + MyVariables.clutchOffset["pitch"]!))," + " \"yaw\": \(String(describing: self.lastValues["yaw"]! + MyVariables.clutchOffset["yaw"]!))," + " \"test\": \"false\"," + " \"arm\": \"left\"}").data(using: .utf8)!)
    }
    
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable Save button only when the mapping status is good and an object has been placed
        
        switch frame.worldMappingStatus {
        case .extending, .mapped:
            print("EXTENDING/NORMAL")
            updateValues(session, &(self.curValues), true, false)
            if (orientation == true) {
                clutchOffsetCalculation(lastValues, curValues)
                orientation = false
            }
            if (!isClutchBtnPressed) {
                sendTransformationLeft(session)
            }
        case .limited:
            orientation = true
            print("LIMITED")
            updateValues(session, &(self.curValues), false, false)
            if (!isClutchBtnPressed) {
                print("WASSUP")
                sendOrientationLeft(session)
            }
        default:
            break
        }
        gripperValLabel.text = ("\(String(describing: round(gripperVal * 1000) / 10) + "%")")
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
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic // maybe comment this out and see
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
        case (.normal, _) where !isRelocalizingMap:
            message = "Only Orientation Transmitting"
            sessionInfoView.backgroundColor = UIColor.blue
            
        default:
            message = trackingState.localizedFeedback
            sessionInfoView.backgroundColor = UIColor.red
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
}

