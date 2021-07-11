//
//  TitleTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/7/5.
//

import UIKit

protocol TitleTableViewCellDelegate: AnyObject {
    func receiveTitleName(title: String)
}
class TitleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var isChose: UIButton!

    weak var delegate: TitleTableViewCellDelegate?

    // 如果被選擇的話，告訴外面的view傳到資料庫中
    @IBAction func ischoseButtonAction(_ sender: Any) {
        if let titleText = self.titleName.text {
        self.delegate?.receiveTitleName(title: titleText)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isChose.setImage(UIImage(named: "icon_star_white"), for: .normal)
        self.isChose.setImage(UIImage(named: "icon_star_gold"), for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
