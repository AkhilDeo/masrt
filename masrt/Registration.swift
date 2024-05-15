//
//  Registrations.swiftr.swift
//  ARPersistence
//
//  Created by Akhil Deo on 1/18/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import SceneKit
import CoreMotion


class Registration {
    
    @IBOutlet weak var PSMOrientationButton2: RoundedButton!
    @IBOutlet weak var DaVinciOrientationButton2: RoundedButton!
    
    var motionManager: CMMotionManager
    
    init?() {
        motionManager = CMMotionManager()
    }
    required init?(coder aDecoder: NSCoder) {
        motionManager = CMMotionManager()
    }
    
    
    @IBAction func savePSMOrientation(_ sender: Any) {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            if let motion = motionManager.deviceMotion {
                MyVariables.PSMOrientation[0] = motion.attitude.roll
                MyVariables.PSMOrientation[1] = motion.attitude.pitch
                MyVariables.PSMOrientation[2] = motion.attitude.yaw
                print("Roll: \(MyVariables.PSMOrientation[0]), Pitch: \(MyVariables.PSMOrientation[1]), Yaw: \(MyVariables.PSMOrientation[2])")
                MyVariables.savePSMOrientation = true
                PSMOrientationButton2.backgroundColor = UIColor.green
            }
        }
    }
    

    @IBAction func SaveDaVinciOrientation(_ sender: Any) {
        if motionManager.isDeviceMotionAvailable {
                motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
                if let motion = motionManager.deviceMotion {
                    MyVariables.DaVinciOrientation[0] = motion.attitude.roll
                    MyVariables.DaVinciOrientation[1] = motion.attitude.pitch
                    MyVariables.DaVinciOrientation[2] = motion.attitude.yaw
                    print("Roll: \(MyVariables.DaVinciOrientation[0]), Pitch: \(MyVariables.DaVinciOrientation[1]), Yaw: \(MyVariables.DaVinciOrientation[2])")
                    MyVariables.saveDaVinciOrientation = true
                    DaVinciOrientationButton2.backgroundColor = UIColor.green

                }
            }
    }

    
    
    
}
