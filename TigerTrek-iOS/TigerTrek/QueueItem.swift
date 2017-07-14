//
//  QueueItem.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 13/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit

class QueueItem {
    var name: String
    var email: String
    var latitude: Double
    var longitude: Double
    
    //MARK: Initialization
    
    init?(name: String, email: String, latitude: Double, longitude: Double) {
        
        //Name and email are required
        if name.isEmpty || email.isEmpty {
            return nil
        }
        
        self.name = name
        self.email = email
        self.longitude = longitude
        self.latitude = latitude
    }
}
