//
//  NewEventFooterView.swift
//  Collocation
//
//  Created by Alex G on 04.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class NewEventFooterView: UIView {

    @IBAction func addReminderTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationCollocationAddReminder, object: nil)
    }

}
