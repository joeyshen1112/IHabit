//
//  MissionOverViewTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/16.
//

import UIKit
protocol MissionOverViewTableViewCellDelegate: AnyObject {
    func receiveMissionStatusByTitle(isOn: Bool, index: Int, missionName: String)
}

class MissionOverViewTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var missionName: UILabel!
    @IBOutlet weak var missionStopLabel: UILabel!
    @IBOutlet weak var finishDayInMounth: UILabel!
    @IBOutlet weak var missionSwitchMode: UISwitch!
    weak var delegate: MissionOverViewTableViewCellDelegate?
    var userDefault = UserDefaults.standard
    var cellSectionIndex: Int?
    var habitID: Int?
    var userID: Int?

    @IBAction private func missionSwitchModeAction(_ sender: UISwitch) {
        if let index = cellSectionIndex,
           let missionName = self.missionName.text {
            delegate?.receiveMissionStatusByTitle(isOn: sender.isOn, index: index, missionName: missionName)
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
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.clipsToBounds = true
        icon.layer.cornerRadius = 50
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
