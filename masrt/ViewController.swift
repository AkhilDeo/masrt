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

import UIKit
import SceneKit
import ARKit
import Foundation
import CoreMotion


class ContentView: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    var ip_address: String
    @IBOutlet weak var ipAddressInput: UITextField!
    @IBOutlet weak var leftPSMControllerButton: UIButton!
    @IBOutlet weak var rightPSMControllerButton: UIButton!
    @IBOutlet weak var testConnectionButton: UIButton!
    
    var network: UDPClient = UDPClient(address: "227.215.14.176", port: 8080)!
    var ip: ValidIPAddress = ValidIPAddress()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var motionManager: CMMotionManager

    
    
    init() {
        self.ip_address = ""
        motionManager = CMMotionManager()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.ip_address = "227.215.14.176"
        motionManager = CMMotionManager()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyBoardOnTap()
        title = "Home"
        leftPSMControllerButton.setDynamicFontSize()
        rightPSMControllerButton.setDynamicFontSize()
        testConnectionButton.setDynamicFontSize()
        leftPSMControllerButton.showsTouchWhenHighlighted = true
        rightPSMControllerButton.showsTouchWhenHighlighted = true
        testConnectionButton.showsTouchWhenHighlighted = true
    
    }
    
    @IBAction func testConnection(_ sender: RoundedButton) {
        
        if ipAddressInput.text != "" && ip.isValidIPAddress(ipAddressInput.text!) {
            self.ip_address = ipAddressInput.text ?? "227.215.14.176"
            MyVariables.ip_address = self.ip_address
            MyVariables.network = UDPClient(address: ip_address, port: 8080)
            MyVariables.network?.send("{\"test\": \"true\"}".data(using: .utf8)!)
        }
        
    }
    
    @IBAction func goToRightController(_ sender: RoundedButton) {
        
        if ipAddressInput.text != "" && ip.isValidIPAddress(ipAddressInput.text!) {
            self.ip_address = ipAddressInput.text ?? "227.215.14.176"
            MyVariables.ip_address = self.ip_address
            MyVariables.network = UDPClient(address: ip_address, port: 8080)
            let rightPSMController = storyBoard.instantiateViewController(withIdentifier: "PSMRight")
            navigationController?.pushViewController(rightPSMController, animated: true)
        }
        
    }
    
    
    @IBAction func goToLeftController(_ sender: RoundedButton) {
        
        if ipAddressInput.text != "" && ip.isValidIPAddress(ipAddressInput.text!) {
            self.ip_address = ipAddressInput.text ?? "227.215.14.176"
            MyVariables.ip_address = self.ip_address
            MyVariables.network = UDPClient(address: ip_address, port: 8080)
            let leftPSMController = storyBoard.instantiateViewController(withIdentifier: "PSMLeft")
            navigationController?.pushViewController(leftPSMController, animated: true)
        }
        
    }
}

extension UIButton {
    
    func setDynamicFontSize() {
        NotificationCenter.default.addObserver(self, selector: #selector(setButtonDynamicFontSize),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    @objc func setButtonDynamicFontSize() {
        Common.setButtonTextSizeDynamic(button: self, textStyle: .callout)
    }
    
}

class Common {
    
    class func setButtonTextSizeDynamic(button: UIButton, textStyle: UIFont.TextStyle) {
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: textStyle)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
}
