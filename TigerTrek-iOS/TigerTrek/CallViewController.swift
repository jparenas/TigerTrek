//
//  CallViewController.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 5/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit
import CoreLocation

class CallViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to cancel the alert?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.destructive, handler: { action in
            NotificationCenter.default.post(name: Notification.Name("cancel emergency"), object: nil, userInfo: ["email":GIDSignIn.sharedInstance().currentUser.profile.email, "id": GIDSignIn.sharedInstance().currentUser.authentication.idToken])
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
