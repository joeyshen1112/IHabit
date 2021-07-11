//
//  ActorInfoTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/27.
//

import UIKit

class ActorInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var infoDetail: UILabel!
    @IBOutlet weak var infoDetailData: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
