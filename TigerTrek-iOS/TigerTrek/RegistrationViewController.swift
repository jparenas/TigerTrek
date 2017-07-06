//
//  FormViewController.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 4/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit
import Eureka

class RegistrationViewController: FormViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(nextView(notification:)), name: Notification.Name("complete registration"), object: nil)
                
        form +++ Section()
            <<< LabelRow() { row in
                row.title = "In this form you can input data that can ease any identification purposes. If you do not want to fill a specific section, just skip it."
                row.cell.textLabel?.numberOfLines = 0
            }
            +++ Section()
            <<< TextRow(){ row in
                row.title = "Name"
                row.tag = "name"
                row.disabled = true
                row.value = GIDSignIn.sharedInstance().currentUser.profile.name
            }
            <<< TextRow(){ row in
                row.title = "Email"
                row.tag = "email"
                row.disabled = true
                row.value = GIDSignIn.sharedInstance().currentUser.profile.email
            }
            +++ Section()
            <<< TextRow() { row in
                row.title = "Height (ft. and in.)"
                row.tag = "height"
            }
            <<< DecimalRow() { row in
                row.title = "Weight (lb.)"
                row.tag = "weight"
            }
            <<< TextRow() { row in
                row.title = "Hair Color"
                row.tag = "hair"
            }
            <<< TextRow() { row in
                row.title = "Eye color"
                row.tag = "eye"
            }
            <<< TextRow() { row in
                row.title = "House where you are staying"
                row.tag = "house"
            }
            <<< IntRow() { row in
                row.title = "Room Number"
                row.tag = "room"
            }
            <<< TextRow() { row in
                row.title = "Allergies"
                row.tag = "allergies"
            }
            <<< TextAreaRow() { row in
                row.placeholder = "Medications"
                row.tag = "medications"
            }
            <<< TextAreaRow() { row in
                row.placeholder = "Emergency Contact Information"
                row.tag = "contact"
            }
            +++ Section()
            <<< ButtonRow(){
                $0.title = "Save"
            }.onCellSelection { cell, row in

                var dictionary = [String: Any]()
                var row: TextRow? = self.form.rowBy(tag: "name")
                let name = row?.value
                row = self.form.rowBy(tag: "email")
                let email = row?.value
                row = self.form.rowBy(tag: "height")
                let height = row?.value
                row = self.form.rowBy(tag: "hair")
                let hair = row?.value
                row = self.form.rowBy(tag: "eye")
                let eye = row?.value
                row = self.form.rowBy(tag: "house")
                let house = row?.value
                row = self.form.rowBy(tag: "allergies")
                let allergies = row?.value
                
                let intRow: IntRow? = self.form.rowBy(tag: "room")
                let room = intRow?.value
                
                let decimalRow: DecimalRow? = self.form.rowBy(tag: "weight")
                let weight = decimalRow?.value
                
                var textAreaRow: TextAreaRow? = self.form.rowBy(tag: "medications")
                let medications = textAreaRow?.value
                textAreaRow = self.form.rowBy(tag: "contact")
                let contact = textAreaRow?.value
                
                dictionary["name"] = name
                dictionary["email"] = email
                dictionary["height"] = height
                dictionary["weight"] = weight
                dictionary["hair"] = hair
                dictionary["eye"] = eye
                dictionary["house"] = house
                dictionary["room"] = room
                dictionary["allergies"] = allergies
                dictionary["medications"] = medications
                dictionary["contact"] = contact
                dictionary["id"] = GIDSignIn.sharedInstance().currentUser.authentication.idToken
                                
                NotificationCenter.default.post(name: Notification.Name("send registration"), object: nil, userInfo: dictionary)
 
                return
            }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextView(notification: Notification) {
        self.performSegue(withIdentifier: "segueToUnlock", sender: nil)
    }
}
