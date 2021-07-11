//
//  MissionStartTimeTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/9.
//

import UIKit
protocol MissionStartTimeTableViewCellDelegate: AnyObject {
    func receiveStartTime(time: String)
}

class MissionStartTimeTableViewCell: UITableViewCell {
    weak var delegate: MissionStartTimeTableViewCellDelegate?
    @IBOutlet weak var startTime: UIDatePicker!
    let formatter = DateFormatter()
    var time: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        print(startTime.date)
        startTime.addTarget(self, action: #selector(MissionStartTimeTableViewCell.dateChange), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @objc
    private func dateChange(datePicker: UIDatePicker) {
        formatter.dateFormat = "yyyy-MM-dd"
        time = formatter.string(from: datePicker.date)
        if let time = time {
            self.delegate?.receiveStartTime(time: time)
        }
    }
}
