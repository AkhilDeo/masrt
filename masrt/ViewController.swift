/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

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
