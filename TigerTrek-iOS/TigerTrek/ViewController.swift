//
//  ViewController.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 3/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    func nextView(notification: Notification) {
                
        switch(notification.userInfo!["data"]! as! String) {
        case "unlock":
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "UnlockViewController") as UIViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //show window
            appDelegate.window?.rootViewController = view
            
        case "form":
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "RegistrationSegue") as UIViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //show window
            appDelegate.window?.rootViewController = view
            
        case "wrong domain":
            let alert = UIAlertController(title: "Wrong Domain", message: "The email you used is not from DePauw, so you have been signed off.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        default:
            break
        }
        
        //self.performSegue(withIdentifier: "segueToUnlock", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/plus.me"]

        GIDSignIn.sharedInstance().signInSilently()
        
        //GIDSignIn.sharedInstance().disconnect()
        
        NotificationCenter.default.addObserver(self, selector: #selector(nextView(notification:)), name: Notification.Name("login"), object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
