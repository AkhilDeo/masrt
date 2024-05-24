//==============================================================================
/*
#     Software License Agreement (BSD License)
#     Copyright (c) 2024 Akhil Deo <adeo1@jhu.edu>


#     All rights reserved.

#     Redistribution and use in source and binary forms, with or without
#     modification, are permitted provided that the following conditions
#     are met:

#     * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.

#     * Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.

#     * Neither the name of authors nor the names of its contributors may
#     be used to endorse or promote products derived from this software
#     without specific prior written permission.

#     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#     COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#     BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#     LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#     ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#     POSSIBILITY OF SUCH DAMAGE.


#     \author    <adeo1@jhu.edu>
#     \author    Akhil Deo
#     \version   1.0
# */
//==============================================================================

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
