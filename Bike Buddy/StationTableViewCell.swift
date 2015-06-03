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
    @IBOutlet weak var numberOfBikesLabel: UILabel!
    @IBOutlet weak var numberOfAvailableDocksLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
