//
//  AppDelegate.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 3/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit
//import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, URLSessionDelegate {

    var window: UIWindow?
    
    var isSecurity = false
    
    let server = "http://localhost:3000"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                GIDSignIn.sharedInstance().clientID = dict["CLIENT_ID"] as! String
            }
        }
        
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/plus.me"]
        // "https://www.googleapis.com/auth/plus.login" is also one of the scopes... but it's not used.
        GIDSignIn.sharedInstance().delegate = self
        
        //Function
        NotificationCenter.default.addObserver(self, selector: #selector(sendRegistration(notification:)), name: Notification.Name("send registration"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendEmergency(notification:)), name: Notification.Name("emergency"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestInformation(notification:)), name: Notification.Name("request information"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInformation(notification:)), name: Notification.Name("send update"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancelEmergency(notification:)), name: Notification.Name("cancel emergency"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(isSecurity(notification:)), name: Notification.Name("security access"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateQueue(notification:)), name: Notification.Name("update queue"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestEmergencyInformation(notification:)), name: Notification.Name("request emergency information"), object: nil)
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //This function will connect to the server using the specified address and payload and return the JSON data.
    func requestFromServer(request: String, payload: [String:Any],completionHandler: @escaping ([String:Any]) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: payload)
        
        // create post request
        var request = URLRequest(url: URL(string: "\(server)/\(request)")!)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 401 {
                print("User is using bad credentials")
                print("response = \(String(describing: response))")
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                completionHandler(responseJSON)
            }
        }
        
        task.resume()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            // let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken! // Safe to send to the server
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            let domain = user.hostedDomain
            
            if domain == "depauw.edu" {
                //print(idToken)
                //print(fullName)
                
                //Send request to server to verify + update info
                requestFromServer(request: "login", payload: ["token":idToken]) { response in
                    switch (response["userRegistered"] as! Bool) {
                    case false:
                        DispatchQueue.main.async() {
                            // Do stuff to UI. DispatchQueue is required for this kind of changes.
                            NotificationCenter.default.post(name: Notification.Name("login"), object: nil, userInfo: ["data":"form"])
                        }
                    case true:
                        DispatchQueue.main.async() {
                            // Do stuff to UI. DispatchQueue is required for this kind of changes.
                            if response["securityAccess"] as! Bool == true {
                                self.isSecurity = true
                            } else {
                                self.isSecurity = false
                            }
                            NotificationCenter.default.post(name: Notification.Name("login"), object: nil, userInfo:
                                ["data":"unlock"])
                        }
                    }
                }
            } else {
                GIDSignIn.sharedInstance().disconnect()
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil, userInfo: ["data":"wrong domain"])
                print("Wrong domain")
            }
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sendRegistration(notification: Notification) {
        requestFromServer(request: "register", payload: notification.userInfo as! [String:Any]) { response in
            switch (response["userRegistered"] as! Bool) {
            case false:
                //...this shouldn't happen. At all.
                break
            case true:
                DispatchQueue.main.async() {
                    // Do stuff to UI. DispatchQueue is required for this kind of changes.
                    NotificationCenter.default.post(name: Notification.Name("complete registration"), object: nil, userInfo: ["data":"unlock"])
                }
            }
        }
    }
    
    func sendEmergency(notification: Notification) {
        requestFromServer(request: "emergency", payload: notification.userInfo as! [String:Any]) { response in
            return
        }
    }
    
    func requestInformation(notification: Notification) {
        requestFromServer(request: "request", payload: notification.userInfo as! [String:Any]) { response in
            DispatchQueue.main.async() {
                // Do stuff to UI. DispatchQueue is required for this kind of changes.
                NotificationCenter.default.post(name: Notification.Name("update information"), object: nil, userInfo: response)
            }
        }
    }
    
    func updateInformation(notification: Notification) {
        requestFromServer(request: "update", payload: notification.userInfo as! [String:Any]) { response in
            return
        }
    }
    
    func cancelEmergency(notification: Notification) {
        requestFromServer(request: "cancel", payload: notification.userInfo as! [String:Any]) { response in
            return
        }
    }
    
    func isSecurity(notification: Notification) {
        DispatchQueue.main.async() {
            // Do stuff to UI. DispatchQueue is required for this kind of changes.
            NotificationCenter.default.post(name: Notification.Name("security response"), object: nil, userInfo: ["security_access":self.isSecurity])
        }
    }
    
    func updateQueue(notification: Notification) {
        requestFromServer(request: "get-queue", payload: ["id":GIDSignIn.sharedInstance().currentUser.authentication.idToken]) { response in
            DispatchQueue.main.async() {
                // Do stuff to UI. DispatchQueue is required for this kind of changes.
                NotificationCenter.default.post(name: Notification.Name("update notification"), object: nil, userInfo: response)
            }
        }
    }
    
    func requestEmergencyInformation(notification: Notification) {
        requestFromServer(request: "request-emergency", payload: notification.userInfo as! [String:Any]) { response in
            DispatchQueue.main.async() {
                // Do stuff to UI. DispatchQueue is required for this kind of changes.
                NotificationCenter.default.post(name: Notification.Name("emergency information response"), object: nil, userInfo: response)
            }
        }
    }
}

