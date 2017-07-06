//
//  ButtonViewController.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 3/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit
import CoreLocation

class ButtonViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        isAuthorizedtoGetUserLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            //do whatever init activities here.
        }
    }
    
    
    //this method is called by the framework on         locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NotificationCenter.default.post(name: Notification.Name("emergency"), object: nil, userInfo: ["latitude":manager.location!.coordinate.latitude, "longitude": manager.location!.coordinate.longitude, "id": GIDSignIn.sharedInstance().currentUser.authentication.idToken])
        //store the user location here to firebase or somewhere
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    
    @IBAction func emergencyButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToConfirmation", sender: nil)
        locationManager.requestLocation()
    }
    
    @IBAction func nonEmergencyButton(_ sender: UIButton) {
    }
    
    @IBAction func editButton(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToInformation", sender: nil)
    }
    
}
