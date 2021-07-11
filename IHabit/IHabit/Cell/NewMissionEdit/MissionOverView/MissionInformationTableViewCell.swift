//
//  MissionInformationTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/17.
//

import UIKit
protocol MissionInformationTableViewCellDelegate: AnyObject {
    func receiveMissionStatusByItems(isOn: Bool, index: Int, missionName: String)
    // 提醒的按鈕
    func receiveIsRemind(isRemind: Bool, index: Int, missionName: String)
}

class MissionInformationTableViewCell: UITableViewCell {
    @IBOutlet weak var missionEncourage: UILabel!
    @IBOutlet weak var missionStartDay: UILabel!
    @IBOutlet weak var missionSwitchMode: UISwitch!
    @IBOutlet weak var finishDayInMounth: UILabel!
    @IBOutlet weak var continueDay: UILabel!
    @IBOutlet weak var reminderButton: UIButton!
    weak var delegate: MissionInformationTableViewCellDelegate?
    var userDefault = UserDefaults.standard
    var cellSectionIndex: Int?
    var habitID: Int?
    var userID: Int?
    // 習慣名稱
    var missionName: String?

    // 按下提醒的按鈕
    @IBAction private func reminderButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        // 如果是改變狀態要先傳狀態給資料庫
        putData(isRemind: sender.isSelected)
        if let index = cellSectionIndex,
           let missionName = self.missionName {
            delegate?.receiveIsRemind(isRemind: sender.isSelected, index: index, missionName: missionName)
        }
    }
    @IBAction private func missionSwitchModeAction(_ sender: UISwitch) {
        if let index = cellSectionIndex,
           let missionName = self.missionName {
            delegate?.receiveMissionStatusByItems(isOn: sender.isOn, index: index, missionName: missionName)
        }
        userID = userDefault.value(forKey: "userID") as? Int
        guard let habitID = habitID, let userID = userID else {
            return
        }
        let parameters = [
            "habitId": habitID,
            "userId": userID,
            "isClose": sender.isOn
        ] as [String: Any]

        Server.shared.requestPut(path: "/UpdateHabit", parameters: parameters) { response in
            switch response {
            case let .success(data):
                print(data)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    private func putData(isRemind: Bool) {
        userID = userDefault.value(forKey: "userID") as? Int
        guard let habitID = habitID, let userID = userID else {
            return
        }
        let parameters = [
            "habitId": habitID,
            "userId": userID,
            "isInform": isRemind
        ] as [String: Any]

        Server.shared.requestPut(path: "/UpdateHabit", parameters: parameters) { response in
            switch response {
            case let .success(data):
                print(data)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reminderButton.setImage(UIImage(named: "btn_notification_f"), for: .selected)
        self.reminderButton.setImage(UIImage(named: "btn_notification_n"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
