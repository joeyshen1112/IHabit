//
//  MissionSetTimeViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/13.
//

import UIKit
protocol MissionSetTimeViewControllerDelegate: AnyObject {
    func receiveRemindTime(time: String)
    // 時間小時
    func receiveRemindTimeHour(hour: String)
    // 時間分鐘
    func receiveRemindTimeMinutes(minutes: String)
}

class MissionSetTimeViewController: UIViewController {
    @IBOutlet weak var remindLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: MissionSetTimeViewControllerDelegate?
    let addDateAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
    let removeDateAlert = UIAlertController(title: "是否要刪除時間？", message: nil, preferredStyle: .alert)
    let formatter = DateFormatter()
    // 小時
    let hourFormatter = DateFormatter()
    // 分鐘
    let minutesFormatter = DateFormatter()
    let currentTime = CurrentTime()
    var datePicker = UIDatePicker()
    var time: [String] = []
    var userChoseTime: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setAddTimeAlertView()
        setRemoveTimeAlertView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
extension MissionSetTimeViewController: MissionAddRemindTimeCollectionViewCellDelegate {
    func receiveAddTimeBool() {
    }
}
extension MissionSetTimeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard time.isEmpty else {
                remindTimeArrIsFul()
                return
            }
            // 新增時間
            present(addDateAlert, animated: true, completion: nil)
        } else {
            // 刪除時間
            self.userChoseTime = indexPath.row
            present(removeDateAlert, animated: true, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.time.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        // 只有第一個是加號
        case 0:
            return getAddButtonCell(collectionView, cellforItemAt: indexPath)
        default:
            return getRemindTimeCell(collectionView, cellforItemAt: indexPath)
        }
    }

    // 取得第0個『新增時間』的cell
    private func getAddButtonCell(_ collectionView: UICollectionView, cellforItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as? MissionAddRemindTimeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        return cell
    }

    // 取得第0個以外的時間cell
    private func getRemindTimeCell(_ collectionView: UICollectionView, cellforItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as? MissionRemindTimeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.time.text = self.time[indexPath.row - 1]
        return cell
    }

    // 設置一個alert讓使用者新增提醒時間
    private func setAddTimeAlertView() {
        datePicker.frame = CGRect(x: 0, y: 0, width: self.addDateAlert.view.frame.width - 2.5 * 8, height: 5)
        datePicker.locale = Locale(identifier: "zh_CN")
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(self.dateChang), for: .valueChanged)
        addDateAlert.view.addSubview(datePicker)
        let done = UIAlertAction(title: "確認", style: .default) { _ -> Void in
            // 新增時間要傳到外面所以會更新delegate
            self.time.append(self.formatter.string(from: self.datePicker.date))
            self.delegate?.receiveRemindTime(time: self.time[0])
            self.delegate?.receiveRemindTimeHour(hour: self.hourFormatter.string(from: self.datePicker.date))
            self.delegate?.receiveRemindTimeMinutes(minutes: self.minutesFormatter.string(from: self.datePicker.date))
            for temp in self.time {
                print(temp)
            }
            self.collectionView.reloadData()
        }
        addDateAlert.addAction(done)
    }

    // 將時間存進去time陣列中
    @objc
    private func dateChang() {
        formatter.dateFormat = "HH:mm"
        hourFormatter.dateFormat = "HH"
        minutesFormatter.dateFormat = "mm"
    }

    // 設置一個alert讓使用者刪除一個時間
    private func setRemoveTimeAlertView() {
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        self.removeDateAlert.addAction(cancelAction)
        let okAction = UIAlertAction(title: "刪除", style: .destructive) { _ -> Void in
            // 刪除時間也必須要更新傳到外面的delegate
            if let index = self.userChoseTime {
                self.time.remove(at: index - 1)
                self.delegate?.receiveRemindTime(time: "21:00")
                self.collectionView.reloadData()
            }
        }
        self.removeDateAlert.addAction(okAction)
    }

    // 設置一個alert告知使用者提醒時間陣列已滿
    private func remindTimeArrIsFul() {
        let remindTimeArrIsFullAlert = UIAlertController(title: "錯誤", message: "提醒時間已設定", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        remindTimeArrIsFullAlert.addAction(okButton)
        present(remindTimeArrIsFullAlert, animated: true, completion: nil)
    }
}
