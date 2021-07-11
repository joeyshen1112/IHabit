//
//  MissionRemindTimeCollectionViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/13.
//

import UIKit

protocol MissionAddRemindTimeCollectionViewCellDelegate: AnyObject {
    func receiveAddTimeBool()
}
class MissionAddRemindTimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var addTimeLabel: UILabel!
    @IBOutlet weak var addTimeButton: UIButton!
    weak var delegate: MissionAddRemindTimeCollectionViewCellDelegate?

    @IBAction private func addTimeButtonAction(_ sender: Any) {
        delegate?.receiveAddTimeBool()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        addTimeLabel.layer.cornerRadius = 5
        addTimeLabel.layer.borderColor = UIColor(displayP3Red: 186, green: 109, blue: 25, alpha: 1).cgColor
        addTimeLabel.layer.borderWidth = 1
    }
}
