//
//  MissionFilterTagTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/18.
//

import UIKit

protocol MissionFilterTagTableViewCellDelegate: AnyObject {
    func receiveTagName(tagID: Int, tagIsCancel: Bool)
}

class MissionFilterTagTableViewCell: UITableViewCell {
    weak var delegate: MissionFilterTagTableViewCellDelegate?
    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var tagIsChoseButton: UIButton!
    var cellID: Int?
    let userDefault = UserDefaults.standard

    @IBAction private func tagIsChose(_ sender: Any) {
        // 如果button的狀態目前是『被選取』，則回傳false，請下個頁面『刪除』資料
        if tagIsChoseButton.isSelected {
            self.tagIsChoseButton.isSelected = false
            if let cellID = cellID {
                delegate?.receiveTagName(tagID: cellID, tagIsCancel: false)
            }
        // 如果button的狀態目前是『無選取』，則回傳true，請下個頁面『新增』資料
        } else {
            self.tagIsChoseButton.isSelected = true
            if let cellID = cellID {
                delegate?.receiveTagName(tagID: cellID, tagIsCancel: true)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tagIsChoseButton.setImage(UIImage(systemName: "circle"), for: UIControl.State.normal)
        self.tagIsChoseButton.setImage(UIImage(systemName: "circle.fill"), for: UIControl.State.selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
