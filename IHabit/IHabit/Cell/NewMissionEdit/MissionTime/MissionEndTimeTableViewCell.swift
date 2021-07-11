//
//  MissionEndTimeTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/12.
//

import UIKit

protocol MissionEndTimeTableViewCellDelegate: AnyObject {
    func receiveData(insertRowBool: Bool)
}

class MissionEndTimeTableViewCell: UITableViewCell {
    weak var delegate: MissionEndTimeTableViewCellDelegate?
    @IBOutlet weak var segmented: UISegmentedControl!

    @IBAction private func segmentedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            delegate?.receiveData(insertRowBool: false)
        case 1:
            delegate?.receiveData(insertRowBool: true)
        default:
            print("error")
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.segmented.tintColor = UIColor.orange
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
