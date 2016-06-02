//
//  PrayerTableViewCell.swift
//  Mawaqeet
//
//  Created by super-pc on 5/14/16.
//  Copyright © 2016 super-pc. All rights reserved.
//

import UIKit

class PrayerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var prayerName: UILabel!
    @IBOutlet weak var prayerTime: UILabel!
    @IBOutlet weak var prayerDuration: UILabel!
    @IBOutlet weak var isPrayerFinishedLine: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
