//
//  MissionNameTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/9.
//

import UIKit
protocol MissionNameTableViewCellDelegate: AnyObject {
    func receiveMissionName(missionName: String)
}

class MissionNameTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var missionName: UITextField!
    weak var delegate: MissionNameTableViewCellDelegate?
    var placeHolderString = "輸入你想堅持的習慣!"

    override func awakeFromNib() {
        super.awakeFromNib()
        missionName.delegate = self
        missionName.returnKeyType = .done
        missionName.attributedPlaceholder = NSAttributedString(string: placeHolderString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
extension MissionNameTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        missionName.resignFirstResponder()
        if let text = missionName.text {
            delegate?.receiveMissionName(missionName: text)
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let text = missionName.text {
//            delegate?.receiveMissionName(missionName: text)
//        }
        // 新版
        print("textField.text: \(textField.text!)")
        print("range: \(range.location)")
        print("string: \(string)")
        if let text = textField.text {
            delegate?.receiveMissionName(missionName: text + string)
        }
        return true
    }
}
