//
//  MissionIconCollectionViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/14.
//

import UIKit

class MissionIconCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconFrame: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        icon.clipsToBounds = true
        icon.layer.cornerRadius = 50
    }
}
