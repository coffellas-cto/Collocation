//
//  ReminderCell.swift
//  Collocation
//
//  Created by Alex G on 05.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
