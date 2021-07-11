//
//  MissionTagCollectionViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/10.
//

import UIKit

class MissionTagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        tagName.layer.cornerRadius = 5
        tagName.layer.borderColor = UIColor(displayP3Red: 186, green: 109, blue: 25, alpha: 1).cgColor
        tagName.layer.borderWidth = 1
    }
}
