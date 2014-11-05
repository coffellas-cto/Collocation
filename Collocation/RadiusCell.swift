//
//  RadiusCell.swift
//  Collocation
//
//  Created by Alex G on 04.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class RadiusCell: UITableViewCell {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var radiusLabel: UILabel!
        
    func sliderValueChanged() {
        radiusLabel.text = NSString(format: "%.01f m", slider.value)
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationCollocationRadiusChanged, object: slider)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        slider.addTarget(self, action: "sliderValueChanged", forControlEvents: .ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
