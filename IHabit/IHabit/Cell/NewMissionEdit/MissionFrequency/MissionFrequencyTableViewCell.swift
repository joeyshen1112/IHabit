//
//  MissionFrequencyTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/10.
//

import UIKit

protocol MissionFrequencyTableViewCellDelegate: AnyObject {
    func receiveAlertBool(alertBool: Bool)
    func receiveFrequency(frequencyDay: [Int])
}

class MissionFrequencyTableViewCell: UITableViewCell {
    weak var delegate: MissionFrequencyTableViewCellDelegate?
    @IBOutlet weak var sunday: UIButton!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!
    @IBOutlet var allButton: [UIButton]!
    var intArrayTemp: [Int] = [] {
        didSet {
            frequencyDay = intArrayTemp
        }
    }
    var frequencyDay: [Int] = []

    @IBAction private func selectButtonPressed(_ sender: UIButton) {
        buttonImageChange(button: sender)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if frequencyDay.isEmpty {
            frequencyDay = [0, 1, 2, 3, 4, 5, 6]
        }
        weekSet()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    private func weekSet() {
        for button in allButton {
            button.setBackgroundImage(UIImage(named: "frequencyBackground_fill"), for: UIControl.State.normal)
            button.setBackgroundImage(UIImage(named: "frequencyBackground"), for: UIControl.State.selected)
        }
    }
    private func buttonImageChange(button: UIButton) {
        // toggle是讓Bool可以快速切換true/false，精簡程式碼
//        button.isSelected.toggle()
        if button.isSelected {
            button.isSelected = false
            frequencyDay.append(checkDay(button))
        } else {
            button.isSelected = true
            frequencyDay.removeAll { $0 == checkDay(button)
            }
        }
        delegate?.receiveFrequency(frequencyDay: frequencyDay)
        // 所有按鈕都已經被選擇的Bool
        var allButtonSelect = true
        for weekButton in allButton {
            if weekButton.isSelected == false {
                allButtonSelect = false
            }
        }
        if allButtonSelect {
            button.isSelected.toggle()
        }
        self.delegate?.receiveAlertBool(alertBool: allButtonSelect)
    }
    // 判斷是哪一天
    private func checkDay(_ button: UIButton) -> Int{
        switch button {
        case self.sunday:
            return 0
        case self.monday:
            return 1
        case self.tuesday:
            return 2
        case self.wednesday:
            return 3
        case self.thursday:
            return 4
        case self.friday:
            return 5
        case self.saturday:
            return 6
        default:
            return 0
        }
    }
}
