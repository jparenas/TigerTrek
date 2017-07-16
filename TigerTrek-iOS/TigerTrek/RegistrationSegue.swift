//
//  RegistrationPlaceholder.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 4/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit

class RegistrationSegue: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        self.performSegue(withIdentifier: "segueToRegistration", sender: nil)
    }
}
