//
//  StationTableViewCell.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/2/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var numberOfBikesLabel: UILabel!
    @IBOutlet weak var numberOfDocksLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
