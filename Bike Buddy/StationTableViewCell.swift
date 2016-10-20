//
//  StationTableViewCell.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/2/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import BikeBuddyKit

class StationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var numberOfDocksLabel: UILabel!
    @IBOutlet weak var numberOfBikesLabel: UILabel!
    @IBOutlet weak var openDocksDescriptionLabel: UILabel!
    @IBOutlet weak var bikesAvailableDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bikesAvailableDescriptionLabel.text = StringsService.getStringFor(key: "StationsListBikesAvailableLabel")
        self.openDocksDescriptionLabel.text = StringsService.getStringFor(key: "StationsListDocksAvailableLabel")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
