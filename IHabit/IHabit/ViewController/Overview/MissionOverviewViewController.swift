//
//  MissionOverviewViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/16.
//

import UIKit

class MissionOverviewViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyBackground: UIView!

    var userDefault = UserDefaults.standard
    var habitIDs: [Int] = []
    var habitList: [HabitListData] = []
    var missions: [MissionDetailData] = []
    // 是否提醒的陣列
    var isInform: [Bool] = []
    // 習慣名稱
    var missionName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的習慣"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = emptyBackground
        tableView.backgroundView?.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 要先清空missions，避免換畫面累加任務
        self.missions = []
        self.habitIDs = []
        self.isInform = []
        getData()
    }
    // 從資料庫取得資料
    private func getData() {
        // 取得userID
        let userID = self.userDefault.value(forKey: "userID") as? Int

        if let userID = userID {
            // 先拿全部的習慣清單，再取出每個習慣是否關閉
            Server.shared.requestGet(path: "/GetHabitList/\(userID)?isClose=true", parameters: nil) { response in
                switch response {
                case let .success(data):
                    do {
                        let missions = try JSONDecoder().decode([HabitListData].self, from: data)
                        self.habitList = missions
                        self.setHabitIDdata()
                        self.getAllHabit(userID: userID)
                        // 提醒的與否陣列
                        missions.forEach { item in
                            if let isInform = item.isInform {
                                self.isInform.append(isInform)
                            }
                        }
                        if self.habitList.isEmpty {
                            self.tableView.backgroundView?.isHidden = false
                        } else {
                            self.tableView.backgroundView?.isHidden = true
                        }
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
            // 然後將每個id給與missions，讓他可以被顯示
        }
    }
    // 取得習慣總覽的所有任務細項
    private func getAllHabit(userID: Int) {
        var count = 0
        for habitID in self.habitIDs {
            print("習慣名稱中\(habitID)")
            Server.shared.requestGet(path: "/GetHabitDetail/\(habitID)/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    do {
                        let missions = try JSONDecoder().decode(MissionDetailData.self, from: data)
                        self.missions.append(missions)
                        // 將每個習慣的是否提醒時間放入陣列中
                        if let isInform = missions.isInform {
                            self.isInform.append(isInform)
                        }
                        // 為了計算到總共習慣的數量後再做更新
                        count += 1
                        if count == self.habitIDs.count {
                            // 這是為了排順序
                            self.missions = self.missions.sorted { $0.habitId! < $1.habitId! }
                            self.tableView.reloadData()
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
    // 設定所有習慣ID
    private func setHabitIDdata() {
        self.habitList.forEach { item in
            if let habitID = item.habitId {
                self.habitIDs.append(habitID)
            }
            print("習慣名稱前\(item.habitName)")
        }
        self.userDefault.setValue(self.habitIDs, forKey: "HabitIDs")
    }
    // 發送put給後端，告知習慣isColse變更(以及提醒的是與否)
    private func changeHabitIsClose(habitId: Int, isClose: Bool) {
        let userID = userDefault.value(forKey: "userID") as? Int

        if let userID = userID {
            let parameters = [
                "habitId": habitId,
                "userId": userID,
                "isClose": isClose
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
    }
    // 推播通知建立
    private func setRemindTime(missionName: String, hour: Int, minute: Int) {
        // 將時間放入提醒的推播通知系統中
        let content = UNMutableNotificationContent()
        content.title = "今天執行\(missionName)了嗎？"
        content.body = "趕快回來執行習慣唷"
        content.sound = UNNotificationSound.default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: missionName, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
// MARK: - 處理TitleCell的delegate
extension MissionOverviewViewController: MissionOverViewTableViewCellDelegate {
    func receiveMissionStatusByTitle(isOn: Bool, index: Int, missionName: String) {
        // 有傳進去就代表要開啟任務，則如果任務開始，就要先判斷原先是否有通知，若有則就要建立通知
        if isOn == true {
            missions[index].isClose = false
            // 如果開啟後，發現這個任務得提醒為true，則要再發通知
            if let isInform = missions[index].isInform, isInform == true {
                // 把時間拆分成hour與minute
                let timeArray = self.missions[index].informTime?.split(separator: ":")
                if let timeArray = timeArray,
                   let hour = Int(timeArray[0]),
                   let minute = Int(timeArray[1]) {
                    self.setRemindTime(missionName: missionName, hour: hour, minute: minute)
                }
            }
            // 發送訊息給後端表示習慣任務得isClose值
            if let habitId = missions[index].habitId, let isClose = missions[index].isClose {
                self.changeHabitIsClose(habitId: habitId, isClose: isClose)
            }
            tableView.reloadData()
        }
    }
}
// MARK: - 處理ItemsInformation的delegate
extension MissionOverviewViewController: MissionInformationTableViewCellDelegate {
    // 得到這個任務是否暫停，暫停包括暫停提醒
    func receiveMissionStatusByItems(isOn: Bool, index: Int, missionName: String) {
        // 有進去代表關掉任務，不管有無任務通知，都直接刪除即可
        if isOn == false {
            missions[index].isClose = true
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(missionName)"])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(missionName)"])

            // 發送訊息給後端表示習慣任務得isClose值
            if let habitId = missions[index].habitId, let isClose = missions[index].isClose {
                self.changeHabitIsClose(habitId: habitId, isClose: isClose)
            }
            tableView.reloadData()
        }
    }
    func receiveIsRemind(isRemind: Bool, index: Int, missionName: String) {
        // 如果打開代表要提醒
        if isRemind {
            let timeArray = self.missions[index].informTime?.split(separator: ":")
            if let timeArray = timeArray,
               let hour = Int(timeArray[0]),
               let minute = Int(timeArray[1]) {
                self.setRemindTime(missionName: missionName, hour: hour, minute: minute)
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(missionName)"])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(missionName)"])
        }
    }
}
// MARK: - 處理TableView的delegate
extension MissionOverviewViewController: UITableViewDelegate, UITableViewDataSource {
    // 針對只有特定cell才可以右滑刪除
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .delete
        }
        return .none
    }
    // 刪除習慣任務 /DeleteHabit/{habitId}/{userId}
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let userID = userDefault.value(forKey: "userID") as? Int
        let habitID = missions[indexPath.section].habitId

        if let userId = userID, let habitId = habitID {
            let parameters = [
                "userId": userId,
                "habitId": habitId
            ]
            // 這是要讓habitID與missions先清空，再重新抓取資料，否則會重疊
            self.habitIDs = []
            self.missions = []
            Server.shared.requestDelete(path: "/DeleteHabit/\(habitId)/\(userId)", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    self.getData()
                    self.tableView.reloadData()
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        missions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 如果此習慣有開啟，則這一個Section內容為兩個row(Title與items)
        if let missionIsClose = missions[section].isClose {
            if !missionIsClose {
                return 2
            } else {
                return 1
            }
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return getMissionTitleCell(tableView, cellForRowAt: indexPath)
        } else {
            return getMissionInformationCell(tableView, cellForRowAt: indexPath)
        }
    }

    // 取得Mission tilte Cell的內容
    private func getMissionTitleCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCellTitle") as? MissionOverViewTableViewCell else {
            return UITableViewCell()
        }
        print("習慣名稱\(missions[indexPath.section].habitName)")
        cell.delegate = self
        cell.habitID = missions[indexPath.section].habitId
        cell.missionName.text = missions[indexPath.section].habitName
        cell.finishDayInMounth.text = "｜\(missions[indexPath.section].completeDaysOfMonth ?? 0)天"
        if let icon = missions[indexPath.section].icon {
            cell.icon.image = UIImage(named: icon)
        }
        // 如果今天是展開狀態(open = true) switch就是 隱藏 = true
        if let isClose = missions[indexPath.section].isClose {
            cell.missionStopLabel.isHidden = !isClose
            cell.missionSwitchMode.isHidden = !isClose
        }
        cell.missionSwitchMode.isOn = false
        cell.cellSectionIndex = indexPath.section
        return cell
    }

    // 取得MissionInformation Cell的內容
    private func getMissionInformationCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionInformationCell") as? MissionInformationTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        // 提醒按鈕
        if self.isInform[indexPath.section] {
            cell.reminderButton.isSelected = true
        } else {
            cell.reminderButton.isSelected = false
        }

        cell.missionName = missions[indexPath.section].habitName
        cell.habitID = missions[indexPath.section].habitId
        cell.missionEncourage.text = missions[indexPath.section].message
        cell.finishDayInMounth.text = "\(missions[indexPath.section].completeDaysOfMonth ?? 0)"
        cell.continueDay.text = "\(missions[indexPath.section].continueDays ?? 0)"
        if let startDate = missions[indexPath.section].startDate {
            cell.missionStartDay.text = "Since \(startDate)"
        }
        cell.missionSwitchMode.isOn = true
        cell.cellSectionIndex = indexPath.section
        return cell
    }
}
