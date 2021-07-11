//
//  StoreViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/27.
//

import UIKit

class StoreViewController: UIViewController {
    @IBOutlet weak var storeBossImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userMoney: UILabel!
    @IBOutlet weak var forginMode: UIButton!
    @IBOutlet weak var forginHammer: UIImageView!
    @IBOutlet weak var levelUpMode: UIButton!
    @IBOutlet weak var levelUpHammer: UIImageView!

    // 測試
    var isReload = false
    // mode 1 = 鍛造；mode 2 = 升階
    var mode = 1
    var userEquip: UserEquipData?
    var userDefault = UserDefaults.standard
    // 計時器
    var myTimer: Timer?
    var count = 0
    private let complete = 100
    // 鍛造目標
    var forgingTarget = ["血量", "魔力", "防禦", "防禦", "血量", "力量"]
    // 鍛造模式
    @IBAction private func forginModeAction(_ sender: Any) {
        self.mode = 1
        self.forginHammer.isHidden = false
        self.levelUpHammer.isHidden = true
        self.tableView.reloadData()
    }
    // 升階模式
    @IBAction private func levelUpModeAction(_ sender: Any) {
        self.mode = 2
        self.levelUpHammer.isHidden = false
        self.forginHammer.isHidden = true
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "商店"
        storeBossImage.image = UIImage.animatedImageNamed("BLACKIDLE", duration: 1)
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.forginHammer.isHidden = false
        self.levelUpHammer.isHidden = true
        getUserequip()
    }
// MARK: - 拿取會員裝備資料
    private func getUserequip() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            Server.shared.requestGet(path: "/UserEquip/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let userEquip = try JSONDecoder().decode(UserEquipData.self, from: data)
                        self.userEquip = userEquip
                        if let money = self.userEquip?.money {
                            self.userMoney.text = "\(money)"
                        }
                        self.tableView.reloadData()
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
extension StoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ForgingCell") as? StoreForgingTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        // 告訴裡面模式
        cell.mode = self.mode
        // 告訴使用者此cell裝備ID
        if let propID = userEquip?.userProps[indexPath.row].propId {
            cell.userEquipItemID = propID
        }
        // 給兩個模式當前使用者有的錢
        if let userHaveMoney = userEquip?.money {
            cell.userHaveMoney = userHaveMoney
            print("使用者還沒鍛造升階前的錢\(userHaveMoney)")
        }
        // 邊框的圖
        cell.bigFrame.image = UIImage(named: "storeFrame\(self.mode)")
        // MARK: - 如果是鍛造模式
        if self.mode == 1 {
            cell.forgingTarget.isHidden = false
            cell.forBuild.isHidden = false
            cell.nameLabel.text = "鍛造"
            cell.isSuccessImage.image = UIImage(named: "rightPoint")
            // propData = 道具數值, buildPrice = 鍛造價格
            if let propData = self.userEquip?.userProps[indexPath.row].propData,
               let buildPrice = self.userEquip?.userProps[indexPath.row].buildPrice,
               let icon = self.userEquip?.userProps[indexPath.row].icon {
                // 鍛造價格(Int)
                cell.price = buildPrice
                // 給予裝備圖示
                cell.userEquipItem.image = UIImage(named: "\(icon)")
                // 鍛造價格
                cell.forgingPrice.text = "\(buildPrice)"
                cell.levelUpIndex.text = "\(propData)"
            }
            cell.forgingTarget.text = self.forgingTarget[indexPath.row]
            cell.userEquipQuality.text = self.forgingTarget[indexPath.row]
        // MARK: - 如果是升階模式
        } else if self.mode == 2 {
            cell.forgingTarget.isHidden = true
            cell.forBuild.isHidden = true
            cell.nameLabel.text = "升階"
            if let upLevelPrice = self.userEquip?.userProps[indexPath.row].upLevelPrice,
               let icon = self.userEquip?.userProps[indexPath.row].icon,
               let level = self.userEquip?.userProps[indexPath.row].level {
                // 升階價格(Int)
                cell.price = upLevelPrice
                // 給予裝備圖示
                cell.userEquipItem.image = UIImage(named: "\(icon)")
                // 升階價格
                cell.forgingPrice.text = "\(upLevelPrice)"
                // 道具起始階級
                cell.userEquipQuality.text = "\(level)"
                // 道具升階後的等級
                let levelTemp = level + 1
                cell.levelUpIndex.text = "\(levelTemp)"
            }
        }

        return cell
    }
// MARK: - 如果金錢不足的話，警告視窗
        private func alertTonNoMoney() {
            let alert = UIAlertController(title: "失敗", message: "當前金錢不足", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
}
// MARK: - 處理回傳的使用者剩的錢，並讓打鐵匠打鐵
extension StoreViewController: StoreForgingTableViewCellDelegate {
    // 是否要因為升階成功而更新tableView
    func reloadTableView(reload: Bool) {
        self.isReload = reload
    }
    // 回傳使用者金錢是否不足
    func moneyIsNotEnough(notEnough: Bool) {
        alertTonNoMoney()
    }
    // 接收使用者剩下的錢，並更新動畫
    func receiveUserMoney(userMoney: Int) {
//        self.userMoney.text = "\(userMoney)"
//        // 鍛造後要更新
//        self.getUserequip()
        // 切換敲打的動畫
        storeBossImage.image = UIImage.animatedImageNamed("BLACKSMITH", duration: 1)
        // 計時器
        myTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(showProgress(sender: )), userInfo: nil, repeats: true)
    }
    @objc
    func showProgress(sender: Timer) {
        // 以一個計數器模擬背景處理的動作
        count += 25
        // 進度完成時
        if count >= complete {
            // 重設計數器及 Timer 供下次按下按鈕測試
            count = 0
            myTimer?.invalidate()
            myTimer = nil
            // 鍛造後要更新
            self.getUserequip()
            // 切回原本的動畫
            storeBossImage.image = UIImage.animatedImageNamed("BLACKIDLE", duration: 1)
        }
    }
}
