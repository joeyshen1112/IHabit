//
//  MissionRemindTimeCollectionViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/14.
//

import UIKit

class MissionRemindTimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        time.layer.cornerRadius = 5
        time.layer.borderColor = UIColor(displayP3Red: 186, green: 109, blue: 25, alpha: 1).cgColor
        time.layer.borderWidth = 1
    }
}
