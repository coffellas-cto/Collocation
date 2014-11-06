//
//  ReminderCell.swift
//  Collocation
//
//  Created by Alex G on 05.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {

    @IBOutlet weak var nameBackView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var switchEnabled: UISwitch!
    
    @IBAction func switchValueChanged(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationCollocationReminderCellSwitchValueChanged, object: self)
        
    }
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameBackView.layer.cornerRadius = 4
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
