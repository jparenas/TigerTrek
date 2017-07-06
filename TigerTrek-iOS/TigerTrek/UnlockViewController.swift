//
//  UnlockViewController.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 3/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit
import LocalAuthentication

class UnlockViewController: UIViewController {
    
    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        var policy: LAPolicy?
        
        policy = .deviceOwnerAuthentication
        
        var err: NSError?
        
        // Check if the user is able to use the policy we've selected previously
        guard context.canEvaluatePolicy(policy!, error: &err) else {
            // Print the localized message received by the system
            return
        }
        
        loginProcess(policy: policy!)
    }
    
    private func loginProcess(policy: LAPolicy) {
        // Start evaluation process with a callback that is executed when the user ends the process successfully or not
        context.evaluatePolicy(policy, localizedReason: "To proceed, we need to verify it's you.", reply: { (success, error) in
            DispatchQueue.main.async {
                guard success else {
                    guard let error = error else {
                        print("Error")
                        return
                    }
                    switch(error) {
                    case LAError.authenticationFailed:
                        print("There was a problem verifying your identity.")
                    case LAError.userCancel:
                        print("Authentication was canceled by user.")
                        GIDSignIn.sharedInstance().disconnect()
                        let alert = UIAlertController(title: "User cancelled action", message: "You cancelled the login action, you have been disconnected. You must login again.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let view = storyboard.instantiateViewController(withIdentifier: "MainViewController") as UIViewController
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        //show window
                        appDelegate.window?.rootViewController = view
                        // Fallback button was pressed and an extra login step should be implemented for iOS 8 users.
                    // By the other hand, iOS 9+ users will use the pasccode verification implemented by the own system.
                    case LAError.userFallback:
                        print("The user tapped the fallback button (Fuu!)")
                    case LAError.systemCancel:
                        print("Authentication was canceled by system.")
                    case LAError.passcodeNotSet:
                        print("Passcode is not set on the device.")
                    case LAError.touchIDNotAvailable:
                        print("Touch ID is not available on the device.")
                    case LAError.touchIDNotEnrolled:
                        print("Touch ID has no enrolled fingers.")
                    // iOS 9+ functions
                    case LAError.touchIDLockout:
                        print("There were too many failed Touch ID attempts and Touch ID is now locked.")
                    case LAError.appCancel:
                        print("Authentication was canceled by application.")
                    case LAError.invalidContext:
                        print("LAContext passed to this call has been previously invalidated.")
                    // MARK: IMPORTANT: There are more error states, take a look into the LAError struct
                    default:
                        print("Touch ID may not be configured")
                        break
                    }
                    return
                }
                
                // Good news! Everything went fine
                self.performSegue(withIdentifier: "segueToButtons", sender: nil)
            }
        })
    }
    
}
