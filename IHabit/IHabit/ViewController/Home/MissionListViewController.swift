//
//  MissionListViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/8.
//

import UIKit
protocol MissionListViewControllerDelegate: AnyObject {
    func finishHabitget(finishHabitGet: FinishHabit)
}

class MissionListViewController: UIViewController {
    @IBOutlet weak var tableViewController: UITableView!
    @IBOutlet var emptyMissionView: UIView!
    weak var delegate: MissionListViewControllerDelegate?
    var userDefault = UserDefaults.standard
    var missions: [HabitListData] = []
    var test: [String] = []
    var userChoseTagID: [Int] = []
    var removeIndex: [Int] = []
    var habitIDs: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewController.delegate = self
        tableViewController.dataSource = self
        tableViewController.backgroundView = emptyMissionView
        tableViewController.backgroundView?.isHidden = true
        tableViewController.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Filter用
        if let userChoseTag = userDefault.value(forKey: "userChoseTag") as? [Int] {
            self.userChoseTagID = userChoseTag
        }
        removeIndex = []
        getData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension MissionListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !self.missions.isEmpty else {
            tableViewController.backgroundView?.isHidden = false
            tableViewController.separatorStyle = .none
            return 0
        }
        tableViewController.backgroundView?.isHidden = true
        tableViewController.separatorStyle = .singleLine
        return missions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? MissionListTableViewCell else {
            return UITableViewCell()
        }
        cell.habitID = missions[indexPath.row].habitId
        cell.missionName.text = missions[indexPath.row].habitName
        // 如果完成，要讓星星填滿 ，有報錯問題（但第二次沒測出來）
        if let isDone = missions[indexPath.row].isDone, isDone {
            cell.missionFinishButton.isSelected = true
        } else {
            cell.missionFinishButton.isSelected = false
        }
        if let iconData = missions[indexPath.row].icon {
            cell.missionIcon.image = UIImage(named: iconData)
        }
        cell.delegate = self
        cell.missionEditButton.addTarget(self, action: #selector(editMission), for: .touchUpInside)
        return cell
    }

// MARK: - 編輯習慣的按鈕動作，移動到NewMissionView中
    @objc
    private func editMission() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newMissionVC = storyboard.instantiateViewController(identifier: "NewMissionViewController") as? NewMissionViewController
        if let newMissionVC = newMissionVC {
            newMissionVC.isEditing = true
            self.navigationController?.pushViewController(newMissionVC, animated: true)
        }
    }
// MARK: - 取得資料庫資料
    private func getData() {
        // 這兩個要歸零，不然會重複
        self.missions = []
        self.habitIDs = []
        // 一開始登入拿到的userID
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            Server.shared.requestGet(path: "/GetHabitList/" + "\(userID)", parameters: nil) { result in
                switch result {
                case let .success(data):
                    do {
                        let missions = try JSONDecoder().decode([HabitListData].self, from: data)
                        self.missions = missions
                        // 如果今天有標籤Filter則：
                        if !self.userChoseTagID.isEmpty {
                            var deleteArray: [Int] = []
                            for index in 0 ..< self.missions.count {
                                if self.filterTag(tagData: self.missions[index].tags) {
                                    deleteArray.append(index)
                                }
                            }
                            self.missions.remove(at: deleteArray)
                        }
                        self.tableViewController.reloadData()
                        // 將所有的habitID存起來，方便詳細清單頁面可用
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
// MARK: - Filter標籤
    private func filterTag(tagData: [HabitListData.Tags]) -> Bool {
        guard !tagData.isEmpty else {
            return true
        }
        var isDelete = true
        // 只要有一個對上，就代表false（是使用者所想要的，不要刪除）
        for tag in tagData {
            if tag.tagId == self.userChoseTagID.first {
                isDelete = false
            }
        }
        return isDelete
    }
}
// MARK: - 取得missionList的delegate
extension MissionListViewController: MissionListTableViewCellDelegate {
    // 傳給編輯頁面使用者點選了哪個習慣
    func cellIsChose(name: String) {
        for mission in missions {
            if mission.habitName == name {
                self.userDefault.setValue(mission.habitId, forKey: "editHabit")
            }
        }
    }
    // 傳到主畫面表示今天使用者完成任務獲得的金錢與經驗值
    func cellIsDone(finishHabitGet: FinishHabit) {
        self.getData()
        self.delegate?.finishHabitget(finishHabitGet: finishHabitGet)
    }
}
