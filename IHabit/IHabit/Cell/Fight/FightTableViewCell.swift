//
//  FightTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/7/1.
//

import UIKit

class FightTableViewCell: UITableViewCell {
    @IBOutlet weak var fightMessage: UILabel!
    @IBOutlet weak var whoImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
