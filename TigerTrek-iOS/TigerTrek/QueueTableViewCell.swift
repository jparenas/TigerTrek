//
//  QueueTableViewCell.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 13/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit
import MapKit

class QueueTableViewCell: UITableViewCell, MKMapViewDelegate {
    
    //MARK: Properties

    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
