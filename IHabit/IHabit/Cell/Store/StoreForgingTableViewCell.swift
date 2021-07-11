//
//  StoreForgingTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/28.
//

import UIKit
protocol StoreForgingTableViewCellDelegate: AnyObject {
    func receiveUserMoney(userMoney: Int)
    func moneyIsNotEnough(notEnough: Bool)
    func reloadTableView(reload: Bool)
}
// 鍛造
class StoreForgingTableViewCell: UITableViewCell {
    @IBOutlet weak var progressUp: UIProgressView!
    @IBOutlet weak var forgingButton: UIButton!
    // 角色裝備圖
    @IBOutlet weak var userEquipItem: UIImageView!
    // 角色裝備原先素質
    @IBOutlet weak var userEquipQuality: UILabel!
    // 當前鍛造價格
    @IBOutlet weak var forgingPrice: UILabel!
    // 鍛造目標
    @IBOutlet weak var forgingTarget: UILabel!
    // 箭頭
    @IBOutlet weak var isSuccessImage: UIImageView!
    // 升階後的等級提示
    @IBOutlet weak var levelUpIndex: UILabel!
    @IBOutlet weak var bigFrame: UIImageView!
    // 執行下面的Label
    @IBOutlet weak var nameLabel: UILabel!
    // 只有鍛造才需要的圖
    @IBOutlet weak var forBuild: UIImageView!
    weak var delegate: StoreForgingTableViewCellDelegate?
    var userDefault = UserDefaults.standard
    // 鍛造的API
    var userForginEquip: UserForgingEquipData?
    // 升階的API
    var userLevelUpEquip: UserLevelUpEquipData?
    // 升階是否成功Bool
    var isSuccessLevelUp = false
    // 裝備ID
    var userEquipItemID: Int?
    // 裝備素質Temp
    var userEquipQualityTemp: Int?
    // 模式
    var mode: Int?
    // 裝備升階與鍛造的金額(Int)
    var price: Int?
    // 使用者還沒鍛造升階前的錢
    var userHaveMoney: Int?
    // 使用者剩下的錢，要回傳給外面頁面
    var userMoney: Int?

    var count = 0
    private let complete = 100
    // 計時器
    var myTimer: Timer?
    // 按下開始鍛造的按鈕行為
    @IBAction private func forgingButtonAction(_ sender: Any) {
        guard let userHaveMoney = self.userHaveMoney,
              let price = self.price,
              userHaveMoney >= price else {
            delegate?.moneyIsNotEnough(notEnough: true)
            return
        }
        print("$$$\(userHaveMoney)")
        self.isSuccessImage.image = UIImage(named: "rightPoint")
        if self.mode == 1 {
            // 處理鍛造API
            getFrogingData()
        } else if self.mode == 2 {
            // 處理升階API
            getLevelUpData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.progressUp.transform = CGAffineTransform(scaleX: 1, y: 3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
// MARK: - 處理Post鍛造API資料
    private func getFrogingData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID, let userEquipItemID = userEquipItemID {
            let parameters = [
                "userId": userID,
                "propId": userEquipItemID
            ]
            Server.shared.requestPost(path: "/BuildProp", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let userForginEquip = try JSONDecoder().decode(UserForgingEquipData.self, from: data)
                        // 拿到資料後給予資料，propData = 數值
                        if let money = userForginEquip.data.money, let propData = userForginEquip.data.propData {
                            self.userHaveMoney = money
                            // 告訴外面使用者現在剩下多少錢
                            self.delegate?.receiveUserMoney(userMoney: money)
                            // 鍛造後得數值，存進暫存中
                            self.userEquipQualityTemp = propData
                        }
                        // 計時器的功能
                        self.forgingButton.isEnabled = false
                        self.progressUp.progress = 0
                        self.myTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.showProgress(sender: )), userInfo: nil, repeats: true)
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
// MARK: - 處理Post升階API資料
    private func getLevelUpData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID, let userEquipItemID = userEquipItemID {
            let parameters = [
                "userId": userID,
                "propId": userEquipItemID
            ]
            Server.shared.requestPost(path: "/UpPropLevel", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let userLevelUpEquip = try JSONDecoder().decode(UserLevelUpEquipData.self, from: data)
                        self.userLevelUpEquip = userLevelUpEquip
                        // 拿到資料後給予資料，propData = 數值
                        if let money = userLevelUpEquip.data?.money,
                           let propData = userLevelUpEquip.data?.propData,
                           let successBool = userLevelUpEquip.message {
                            // 這邊等美瑩用好，要改一下邏輯，因為如果是失敗，則左邊數值不需要做變化存進暫存
                            self.userHaveMoney = money
                            // 告訴外面使用者現在剩下多少錢
                            self.delegate?.receiveUserMoney(userMoney: money)
                            // 升階成功與否
                            if successBool == "success" {
                                self.isSuccessLevelUp = true
                                // 升階後得數值，存進暫存中
                                self.userEquipQualityTemp = propData
                            } else {
                                self.isSuccessLevelUp = false
                            }
                        }

                        // 計時器的功能
                        self.forgingButton.isEnabled = false
                        self.progressUp.progress = 0
                        self.myTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.showProgress(sender: )), userInfo: nil, repeats: true)
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    @objc
    func showProgress(sender: Timer) {
        // 以一個計數器模擬背景處理的動作
        count += 33

        // 每次都為進度條增加進度
        progressUp.progress =
          Float(count) / Float(complete)

        // 進度完成時
        if count >= complete {
            // 示範 userInfo 傳入的參數
//            var info =
//              sender.userInfo as?
//                Dictionary<String, AnyObject>
//            print(info?["test"])

            // 重設計數器及 NSTimer 供下次按下按鈕測試
            count = 0
            myTimer?.invalidate()
            myTimer = nil

            // 將按鈕功能啟動
            forgingButton.isEnabled = true
            progressUp.progress = 0
            // 等計時器跑完再印鍛造&升階數值
            print("成功與否=>\(self.isSuccessLevelUp)")
            // 鍛造
            if self.mode == 1 {
//                if let userEquipQuality = userEquipQualityTemp {
//                    self.userEquipQuality.text = "\(userEquipQuality)"
//                }
            // 成功升階
            } else if self.mode == 2 && self.isSuccessLevelUp {
                if let userEquipQuality = userEquipQualityTemp {
                    // 升階後左邊要更新
                    self.userEquipQuality.text = "\(userEquipQuality)"
                    // 升階後右邊的目標階級要上升
                    let indexTemp = userEquipQuality + 1
                    self.levelUpIndex.text = "\(indexTemp)"
                }
                delegate?.reloadTableView(reload: true)
            // 失敗升階
            } else if self.mode == 2 && !self.isSuccessLevelUp {
                self.isSuccessImage.image = UIImage(named: "defaultIcon")
            }
        }
    }
}
