//
//  InformationViewController.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 14/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit
import MapKit

class InformationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var hair: UILabel!
    @IBOutlet weak var eye: UILabel!
    @IBOutlet weak var house: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var allergies: UILabel!
    @IBOutlet weak var medications: UILabel!
    @IBOutlet weak var contact: UILabel!
    
    var information = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.post(name: Notification.Name("request emergency information"), object: nil, userInfo: ["id":GIDSignIn.sharedInstance().currentUser.authentication.idToken, "email":information["email"]!])
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInformation(notification:)), name: Notification.Name("emergency information response"), object: nil)
        
        if let mapView = self.mapView
        {
            mapView.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateInformation(notification: Notification) {
        print(notification.userInfo!)
        let data = notification.userInfo as! [String:Any]
        
        name.text = data["name"] as? String
        email.text = data["email"] as? String
        height.text = data["height"] as? String
        weight.text = String(describing: data["weight"]!)
        hair.text = data["hair"] as? String
        eye.text = data["eye"] as? String
        house.text = data["house"] as? String
        room.text = String(describing: data["room"]!)
        allergies.text = data["allergies"] as? String
        medications.text = data["medications"] as? String
        contact.text = data["contact"] as? String
        
        showLocation(location: CLLocation(latitude: Double(data["latitude"] as! String)!, longitude: Double(data["longitude"]  as! String)!))
    }
    
    func showLocation(location:CLLocation) {
        let orgLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = orgLocation
        mapView!.addAnnotation(dropPin)
        self.mapView?.setRegion(MKCoordinateRegionMakeWithDistance(orgLocation, 500, 500), animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to cancel the emergency?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.destructive, handler: { action in
            NotificationCenter.default.post(name: Notification.Name("cancel emergency"), object: nil, userInfo: ["email":self.information["email"]!, "id": GIDSignIn.sharedInstance().currentUser.authentication.idToken])
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

}
