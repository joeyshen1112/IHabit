//
//  NewMissionViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/9.
//

import UIKit

class NewMissionViewController: UIViewController {
    @IBOutlet weak var newMissionTableView: UITableView!
    @IBOutlet weak var missionSetTagViewController: UIView!
    @IBOutlet weak var missionSetTimeViewController: UIView!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    @IBOutlet weak var confirmButton: UIButton!
    let currentTime = CurrentTime()
    let layout = UICollectionViewLayout()
    // 是否為編輯狀態
    var isEditMode = false
    var editMission: MissionDetailData?
    var userDefault = UserDefaults.standard
    var periodTempBool = false
    var tempTagIndex: [Int] = []
    // containerView的兩個內容view
    var missionSetTagVC: MissionSetTagViewController?
    var missionSetTimeVC: MissionSetTimeViewController?
    // 時間相關變數
    var timeLabel = UILabel()
    var time: String = ""
    var datePicker = UIDatePicker()
    // 提醒的hour
    var reminderHour: Int?
    // 提醒的minutes
    var reminderMinutes: Int?
    // 兩個表格長度
    var countOfCollectionView: [Int] = [1, 2, 3, 4, 5, 6]
    var countOfTableView = 4
    // 頻率陣列
    var frequency: [Int] = [7]
    var frequencyString: String?
    // 傳資料庫用的變數
    var missionName: String?
    var missionIcon: String?
    var missionTag: [Int] = []
    var missionEncourage: String?
    var missionStartTime: String?
    var missionRemindTime: String?
    var missionRemindTimeDate: Date?
    var missionFrequency: String?
    var missionIsInform: Bool?

    var iconChoseIndex: Int?
    let frequencySentence = FrequencySentence()

    override func viewDidLoad() {
        super.viewDidLoad()
        newMissionTableView.delegate = self
        newMissionTableView.dataSource = self
        // 禁止這個tableView滑動
        newMissionTableView.isScrollEnabled = false
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        setupChildViewControllers()
        self.confirmButton.layer.cornerRadius = 10
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 如果是編輯狀態進來
        if isEditing {
            self.title = "編輯習慣"
            self.confirmButton.setTitle("修改", for: .normal)
            let habitID = self.userDefault.value(forKey: "editHabit") as? Int
            if let habitID = habitID {
                self.geteditHabitData(habitID: habitID)
            }
            self.periodTempBool = true
        }
        // 每次進入這個頁面都會把時間調會現在時間
        time = currentTime.getCurrentTime()
    }
// MARK: - 如果是編輯狀態近來此畫面，要用這func跑資料
    private func geteditHabitData(habitID: Int) {
        let userID = self.userDefault.value(forKey: "userID") as? Int

        if let userID = userID {
            Server.shared.requestGet(path: "/GetHabitDetail/\(habitID)/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    do {
                        let mission = try JSONDecoder().decode(MissionDetailData.self, from: data)
                        self.editMission = mission
                        // 將要傳的值先預設為使用者要編輯的這個習慣資料
                        // 提醒時間
                        self.missionRemindTime = self.editMission?.informTime
                        // 圖片
                        self.missionIcon = self.editMission?.icon
                        // 標籤
                        self.editMission?.tags.forEach { item in
                            if let tagId = item.tagId {
                                self.tempTagIndex.append(tagId)
                            }
                        }
                        self.missionTag = self.tempTagIndex
                        // 頻率
                        self.frequencyString = self.editMission?.period
                        if self.editMission?.period == "7" {
                            self.countOfTableView = 4
                        } else {
                            self.countOfTableView = 5
                        }
                        // 鼓勵的話
                        self.missionEncourage = self.editMission?.message
                        if let iconNumber = self.editMission?.icon, let number = (Int)(iconNumber) {
                            self.iconChoseIndex = number - 1
                        }
                        // 是否提醒
                        self.missionIsInform = self.editMission?.isInform
                        self.setupChildViewControllers()
                        self.newMissionTableView.reloadData()
                        self.iconCollectionView.reloadData()
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
// MARK: - 設定兩個Container View內容
    private func setupChildViewControllers() {
        // Tag的
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let missionSetTagVC = storyboard.instantiateViewController(identifier: "MissionSetTagViewController") as? MissionSetTagViewController
        if let missionSetTagVC = missionSetTagVC {
            addChild(childController: missionSetTagVC, to: missionSetTagViewController)
        }
        self.missionSetTagVC = missionSetTagVC
        self.missionSetTagVC?.delegate = self
        // 如果是編輯狀態的話，則進入
        if isEditing {
            self.missionSetTagVC?.isEditMode = true
            self.editMission?.tags.forEach { item in
                if let tagId = item.tagId {
                    self.missionSetTagVC?.editTagID.append(tagId)
                }
            }
        }

        // 提醒時間的
        let missionSetTimeVC = storyboard.instantiateViewController(identifier: "MissionSetTimeViewController") as? MissionSetTimeViewController
        if let missionSetTimeVC = missionSetTimeVC {
            addChild(childController: missionSetTimeVC, to: missionSetTimeViewController)
        }
        self.missionSetTimeVC = missionSetTimeVC
        self.missionSetTimeVC?.delegate = self
        // 如果是編輯狀態的話，則進入
        if isEditing, let time = editMission?.informTime {
            self.missionSetTimeVC?.time.append(time)
        }
    }
    // MARK: - 最後確認及存取資料的部分
    @IBAction private func confirmButtonAction(_ sender: Any) {
        guard missionName != nil else {
            alertToNoName()
            return
        }
        if let missionName = missionName, missionName.isEmpty {
            alertToNoName()
            return
        }
        // 編輯狀態進來
        if isEditing {
            changefrequencyToString()
            // 設定推播時間
            setRemindTime()
            let habitID = self.userDefault.value(forKey: "editHabit") as? Int
            let userID = userDefault.value(forKey: "userID")
            let parameters = [
                "habitId": habitID,
                "userId": userID,
                "habitName": missionName,
                "startDate": missionStartTime,
                "period": frequencyString,
                "message": missionEncourage,
                "isInform": missionIsInform,
                "informTime": missionRemindTime,
                "icon": missionIcon
            ]
            // 測試用print
            print("\(userID),\(habitID),\(missionName),\(missionStartTime),\(frequencyString),\(missionEncourage),\(missionRemindTime),\(missionIcon)")
            missionTag.sorted(by: <).forEach { item in
                print("最終：\(item)")
            }
            self.tempTagIndex.sorted(by: <).forEach { item in
                print("原先：\(item)")
            }
            // 查看習慣的標籤是否需要更改
            if self.missionTag.count != self.tempTagIndex.count {
                // 刪除tag,再新增
                changeHabitTags()
            } else {
                for index in 0..<self.missionTag.count {
                    if self.missionTag[index] != self.tempTagIndex[index] {
                        // 刪除tag,再新增
                        changeHabitTags()
                    }
                }
            }
            Server.shared.requestPut(path: "/UpdateHabit", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
            return
        } else {
            // 新建一個新習慣任務
            insertUserData()
        }
    }
    // 新建一個新習慣任務
    private func insertUserData() {
        checkNil()
        changefrequencyToString()
        // 設定推播時間
        setRemindTime()

        let userID = userDefault.value(forKey: "userID")
        let parameters = [
            "userId": userID,
            "habitName": missionName,
            "startDate": missionStartTime,
            "period": frequencyString,
            "message": missionEncourage,
            "isHide": false,
            "isInform": true,
            "informTime": missionRemindTime,
            "icon": missionIcon,
            "isSocailized": true,
            "isClose": false,
            "tags": missionTag
        ]
        // 測試api用列印
        print("\(userID),\(missionName),\(missionStartTime),\(frequencyString),\(missionEncourage),\(missionRemindTime),\(missionIcon)")
        self.missionTag.forEach { item in
            print("@@\(item)")
        }
        // missions.missionIsOpen = true
        // startTime, icon,remindTime  有可能是nil
        // tag 不會是nil，但有可能是空陣列
        Server.shared.requestPost(path: "/AddHabit", parameters: parameters) { response in
            switch response {
            case let .success(data):
                print("成功新增\(data)")
                self.navigationController?.popViewController(animated: true)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    // 推播時間設定
    private func setRemindTime() {
        // 把提醒時間加入推播中
        if let reminderHour = self.reminderHour,
           let reminderMinutes = self.reminderMinutes,
           let missionName = self.missionName {
            // 將時間放入提醒的推播通知系統中
            let content = UNMutableNotificationContent()
            content.title = "今天執行\(missionName)了嗎？"
            content.body = "趕快回來執行習慣唷"
            content.sound = UNNotificationSound.default

            var date = DateComponents()
            date.hour = reminderHour
            date.minute = reminderMinutes

            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let request = UNNotificationRequest(identifier: missionName, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    // 如果使用者沒有輸入這些資訊的話，給他預設值
    private func checkNil() {
        if missionIcon == nil {
            missionIcon = "6"
        }
        if missionStartTime == nil {
            missionStartTime = self.time
        }
        if missionRemindTime == nil {
            missionRemindTime = "21:00"
            self.reminderHour = 21
            self.reminderMinutes = 00
        }
    }
    // 轉換frequency成String
    private func changefrequencyToString() {
        var temp: String = ""
        frequency.forEach { item in
            if item == frequency.first {
                temp += "\(item)"
            } else {
                temp += ",\(item)"
            }
        }
        frequencyString = temp
    }
    // 刪除標籤並新增標籤
    private func changeHabitTags() {
        let habitID = self.userDefault.value(forKey: "editHabit") as? Int
        if let habitID = habitID {
            // 刪除的動作
            self.tempTagIndex.forEach { index in
                let parameters = [
                    "habitId": habitID,
                    "tagId": index
                ] as [String: Any]
                Server.shared.requestDelete(path: "/DeleteHabitTag", parameters: parameters) { response in
                    switch response {
                    case let .success(data):
                        print(data)
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
            }

            // 新增的動作
            self.missionTag.forEach { item in
                let parameters = [
                    "habitId": habitID,
                    "tagId": item
                ] as [String: Any]
                Server.shared.requestPost(path: "/AddHabitTag", parameters: parameters) { response in
                    switch response {
                    case let .success(data):
                        print(data)
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

// MARK: - 處理newMissionTableView各個Delegate的部分

// 處理儲存習慣名稱的delegate
extension NewMissionViewController: MissionNameTableViewCellDelegate {
    func receiveMissionName(missionName: String) {
        self.missionName = missionName
    }
}

// 處理時間(永遠還是每週)的delegate
extension NewMissionViewController: MissionEndTimeTableViewCellDelegate {
    func receiveData(insertRowBool: Bool) {
        if insertRowBool {
            self.countOfTableView += 1
            self.newMissionTableView.reloadData()
        } else {
            self.countOfTableView -= 1
            self.newMissionTableView.reloadData()
        }
    }
}

// 處理時間頻率的delegate
extension NewMissionViewController: MissionFrequencyTableViewCellDelegate {
    func receiveAlertBool(alertBool: Bool) {
        if alertBool {
            let alertView = UIAlertController(title: "錯誤", message: "至少要選擇一天進行習慣", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
            alertView.addAction(okButton)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    // 傳頻率時間出來
    func receiveFrequency(frequencyDay: [Int]) {
        frequency = frequencyDay.sorted(by: <)
        // 測試用
        frequency.forEach { item in
            print("@@@@\(item)")
        }
    }
}
// 處理開始時間的Delegate
extension NewMissionViewController: MissionStartTimeTableViewCellDelegate {
    func receiveStartTime(time: String) {
        missionStartTime = time
    }
}

// 處理標籤MissionSetTagViewController的delegate
extension NewMissionViewController: MissionSetTagViewControllerDelegate {
    func receiveTagName(tagId: [Int]) {
        missionTag = tagId
    }
}

// 處理Encourage的資料傳遞
extension NewMissionViewController: MissionEncourageTableViewCellDelegate {
    func receiveSentence(encourage: String) {
        missionEncourage = encourage
    }
}

// 處理MissionSetTimeViewController的delegate
extension NewMissionViewController: MissionSetTimeViewControllerDelegate {
    func receiveRemindTime(time: String) {
        missionRemindTime = time
    }
    // 時間小時
    func receiveRemindTimeHour(hour: String) {
        // 提醒的hour
        reminderHour = Int(hour)
    }
    // 時間分鐘
    func receiveRemindTimeMinutes(minutes: String) {
        // 提醒的minutes
        reminderMinutes = Int(minutes)
    }
}

// MARK: - 處理iconCollectionView的部分
extension NewMissionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 選擇得圖片編號
        iconChoseIndex = indexPath.row
        missionIcon = "\(indexPath.row + 1)"
        collectionView.reloadData()
        return
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        28
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as? MissionIconCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.icon.image = UIImage(named: "\(indexPath.row + 1)")
        cell.clipsToBounds = true
        cell.icon.layer.cornerRadius = 10
        if let iconChoseIndex = iconChoseIndex, iconChoseIndex == indexPath.row {
            cell.iconFrame.isHidden = false
        } else {
            cell.iconFrame.isHidden = true
        }
        return cell
    }
}

// MARK: - 新建任務頁面中的TableView
extension NewMissionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countOfTableView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.countOfTableView == 5 {
            switch indexPath.row {
            case 0:
                return getMissionNameCell(tableView, cellForRowAt: indexPath)
            case 1:
                return getMissionStartTimeCell(tableView, cellForRowAt: indexPath)
            case 2:
                return getMissionEndTimeCell(tableView, cellForRowAt: indexPath)
            case 3:
                return getFrequencyCell(tableView, cellForRowAt: indexPath)
            case 4:
                return getEncourageCell(tableView, cellForRowAt: indexPath)
            default:
                return UITableViewCell()
            }
        }
        switch indexPath.row {
        case 0:
            return getMissionNameCell(tableView, cellForRowAt: indexPath)
        case 1:
            return getMissionStartTimeCell(tableView, cellForRowAt: indexPath)
        case 2:
            return getMissionEndTimeCell(tableView, cellForRowAt: indexPath)
        case 3:
            return getEncourageCell(tableView, cellForRowAt: indexPath)
        default:
            return UITableViewCell()
        }
    }
    // 取得第一個cell
    private func getMissionNameCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionName") as? MissionNameTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        // 編輯狀態進來有預設
        if isEditing {
            cell.missionName.placeholder = self.editMission?.habitName
            self.missionName = self.editMission?.habitName
        }
        return cell
    }
    // 取得第二個cell
    private func getMissionStartTimeCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionStart") as? MissionStartTimeTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        // 編輯狀態進來有預設
        if isEditing, let dateString = self.editMission?.startDate {
            let date = stringToDate(dateString, dateFormat: "yyyy-MM-dd")
            if let date = date {
                cell.startTime.date = date
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.missionStartTime = formatter.string(from: datePicker.date)
            }
        }
        return cell
    }
    // 取得第三個cell(是頻率的永遠與每週的欄位)
    private func getMissionEndTimeCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionEnd") as? MissionEndTimeTableViewCell else {
            return UITableViewCell()
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
        cell.delegate = self
        // 編輯狀態進來有預設
        if self.countOfTableView == 4 {
            cell.segmented.selectedSegmentIndex = 0
        } else {
            cell.segmented.selectedSegmentIndex = 1
        }
        return cell
    }
    // 取得第四個cell
    private func getEncourageCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Encourage") as? MissionEncourageTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        // 編輯狀態進來有預設
        if isEditing {
            cell.userWriteTextField.placeholder = self.editMission?.message
        } else {
            missionEncourage = randomSentence()
            cell.userWriteTextField.placeholder = missionEncourage
        }
        return cell
    }
    // 取得第五個cell
    private func getFrequencyCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Frequency") as? MissionFrequencyTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        // 編輯狀態進來有預設，
        if isEditing, let array = self.editMission?.period {
            guard self.editMission?.period != "7" else {
                return cell
            }
            cell.allButton.forEach { item in
                item.isSelected = true
            }
            var tempIntArray: [Int] = []
            for chr in array {
                if chr == "," {
                    continue
                }
                tempIntArray.append((Int)(String(chr)) ?? 0)
                switch chr {
                case "0":
                    cell.sunday.isSelected = false
                case "1":
                    cell.monday.isSelected = false
                case "2":
                    cell.monday.isSelected = false
                case "3":
                    cell.wednesday.isSelected = false
                case "4":
                    cell.thursday.isSelected = false
                case "5":
                    cell.friday.isSelected = false
                case "6":
                    cell.saturday.isSelected = false
                default:
                    print("error")
                }
            }
            cell.frequencyDay = tempIntArray
        }
        return cell
    }
    // 判斷有幾行row時的共同func
    private func setTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) {
    }
    // 底下跳出DatePicker讓使用者選時間
    private func alertTimeClick() {
        let dateAlert = UIAlertController(title: "\n\n\n\n", message: "", preferredStyle: .actionSheet)
        datePicker.frame = CGRect(x: 0, y: 0, width: 500, height: 200)
        datePicker.locale = Locale(identifier: "zh_CN")
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChange), for: .valueChanged)
        dateAlert.view.addSubview(self.datePicker)
        let cancel = UIAlertAction(title: "清除", style: .cancel, handler: nil)
        dateAlert.addAction(cancel)
        let done = UIAlertAction(title: "確認", style: .default) { _ -> Void in
            self.newMissionTableView.reloadData()
        }
        dateAlert.addAction(done)
        present(dateAlert, animated: true, completion: nil)
    }
    // 輸入日期
    @objc
    private func dateChange() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        print(formatter.string(from: datePicker.date))
        self.time = formatter.string(from: datePicker.date)
    }
    // 轉換方法
    private func stringToDate(_ string: String, dateFormat: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.date(from: string)
        return date
    }
    // 隨機給鼓勵話語
    private func randomSentence() -> String {
        return frequencySentence.getSentence(index: Int.random(in: 0...frequencySentence.getSentenceCount() - 1))
    }
    // 沒有輸入名字要跳出的警告視窗
    private func  alertToNoName() {
        let noNameAlert = UIAlertController(title: "錯誤", message: "請輸入習慣名稱", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        noNameAlert.addAction(okButton)
        present(noNameAlert, animated: true, completion: nil)
    }
}
