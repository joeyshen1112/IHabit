//
//  MissionListTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/8.
//

import UIKit
protocol MissionListTableViewCellDelegate: AnyObject {
    // 傳回去使用者點擊了哪個cell去做編輯
    func cellIsChose(name: String)
    // 傳回去使用者點擊後獲得的經驗值與天賦點數跟金幣
    func cellIsDone(finishHabitGet: FinishHabit)
}

class MissionListTableViewCell: UITableViewCell {
    @IBOutlet weak var missionName: UILabel!
    @IBOutlet weak var missionIcon: UIImageView!
    @IBOutlet weak var missionFinishButton: UIButton!
    @IBOutlet weak var missionEditButton: UIButton!
    weak var delegate: MissionListTableViewCellDelegate?
    var userDefault = UserDefaults.standard
    var finishHabitGetList: FinishHabit?
    let currentTime = CurrentTime()
    var time: String = ""
    var habitID: Int?

    // 編輯的按鈕動作
    @IBAction private func missionEditButtonAction(_ sender: Any) {
        if let missionName = missionName.text {
            delegate?.cellIsChose(name: missionName)
        }
    }
    // 完成任務的動作
    @IBAction private func missionDoneAction(_ sender: Any) {
//        guard missionFinishButton.isSelected == false else {
//            return
//        }
//        missionFinishButton.isSelected.toggle()
        postFinishHabitData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.missionFinishButton.setImage(UIImage(named: "icon_star_white"), for: UIControl.State.normal)
        self.missionFinishButton.setImage(UIImage(named: "icon_star_gold"), for: UIControl.State.selected)
        missionIcon.clipsToBounds = true
        missionIcon.layer.cornerRadius = 10
        // 每次進入這個頁面都會把時間調會現在時間
        time = currentTime.getCurrentTime()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    // 上傳完成任務的post給後端
    private func postFinishHabitData() {
        if  let habitID = habitID {
            let parameters = [
                "habitId": habitID,
                "date": self.time
            ] as [String: Any]
            print("###\(self.time)")
            Server.shared.requestPost(path: "/AddHabitDoneDate", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let finishHabitGetList = try JSONDecoder().decode(FinishHabit.self, from: data)
                        self.finishHabitGetList = finishHabitGetList
                        self.delegate?.cellIsDone(finishHabitGet: finishHabitGetList)
                        if let temp = self.finishHabitGetList {
                            print("!!!!!\(temp.exp),\(temp.talentPoint),\(temp.level),\(temp.money)")
                        }
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
