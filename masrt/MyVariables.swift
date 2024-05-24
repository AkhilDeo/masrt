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
import SceneKit

struct MyVariables {
    static var ip_address = "0.0.0.0"
    static var network: UDPClient? = nil
    
    // for ecm,  joint 1 controls yaw, joint 2 controls pitch, joint 3 controls insertion, and joint 4 controls the roll
    static var camera_jp: Array<Float> = [0.0, 0.0, 0.0, 0.0]
    static var clutchOffset: Dictionary<String, Float> = ["x": 0.0,
                                                          "y": 0.0,
                                                          "z": 0.0,
                                                          "roll": 0.0,
                                                          "pitch": 0.0,
                                                          "yaw": 0.0 ]
    static var PSMOrientation: Array<Double> = [0, 0, 0]
    static var DaVinciOrientation: Array<Double> = [0, 0, 0]
    static var savePSMOrientation: Bool = false
    static var saveDaVinciOrientation: Bool = false
    static var changeCoordinates: Bool = false
    static var angle: Double = 0.0
    static var rotationMatrix: simd_float3x3 = float3x3([
        simd_float3(1, 0, 0),
        simd_float3(0, 1, 0),
        simd_float3(0, 0, 1)
    ])
}
