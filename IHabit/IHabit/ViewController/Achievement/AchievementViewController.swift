//
//  AchievementViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/6.
//

import UIKit

class AchievementViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var talentPoint: UILabel!
    // 天賦點的陣列
    @IBOutlet var talentArray: [UIButton]!

    var userDefault = UserDefaults.standard
    // 天賦資料
    var talentList: TalentListData?
    // 天賦節點與上個節點
    var talentDictionary = [String: String]()
    // 剩餘天賦點數
    var talentPointInt: Int?
    // 取得天賦的圖名路徑
    var talentGetImage = "difficulty_point_on"
    // 非取得天賦的圖名路徑
    var talentNotGetImage = "difficulty_point_off"
    var fullSize: CGSize?
    // 學習天賦的按鈕動作
    @IBAction private func ID1Action(_ sender: UIButton) {
        // 如果是前六個天賦，則只需要夠天賦點即可
        if sender.isSelected == false,
           let talentPointInt = self.talentPointInt,
           let titleLabelText = sender.titleLabel?.text,
           let titleLabelTextInt = Int(titleLabelText),
           titleLabelTextInt > 0,
           titleLabelTextInt < 7,
           talentPointInt > 0 {
            self.alertToCheckLearn(button: sender)
            return
        }
        // 如果今天天賦尚未學習，而且還有天賦點
        if sender.isSelected == false,
           let talentPointInt = self.talentPointInt,
           let titleLabelText = sender.titleLabel?.text,
           talentPointInt > 0 {
            // 先檢查是否跳接學習
            // 現在點擊節點的上個節點
            let nodeLastNode = self.talentDictionary[titleLabelText]
            talentArray.forEach { item in
                if let lastNodeId = item.titleLabel?.text,
                   lastNodeId == nodeLastNode {
                    if item.isSelected {
                        self.alertToCheckLearn(button: sender)
                    } else {
                        self.alertToNotLearn()
                    }
                }
            }
        } else if sender.isSelected == false,
                  let talentPointInt = self.talentPointInt,
                  talentPointInt < 1 {
            // 天賦點不足警告
            alertToNotEnoughTalent()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fullSize = UIScreen.main.bounds.size
        scrollView.delegate = self
        scrollView.bouncesZoom = true
        scrollView.scrollsToTop = false
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 0.3
        scrollView.maximumZoomScale = 2.0
        scrollView.contentOffset = CGPoint(x: 1000, y: 840)
        // 設定所有天賦點的背景圖
        self.talentArray.forEach { item in
            item.setBackgroundImage(UIImage(named: "difficulty_point_on"), for: .selected)
            item.setBackgroundImage(UIImage(named: "difficulty_point_off"), for: .normal)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getTalentData()
    }

// MARK: - 拿取天賦資料
    private func getTalentData() {
        let userID = self.userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            Server.shared.requestGet(path: "/Talent/NodeList/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let talentList = try JSONDecoder().decode(TalentListData.self, from: data)
                        self.talentList = talentList
                        // 串剩餘天賦點數
                        if let talentPoint = self.talentList?.talentPoint {
                            self.talentPoint.text = "\(talentPoint)點"
                            self.talentPointInt = talentPoint
                        }
                        // 顯示當前有哪些天賦已點
                        if let nodesCount = self.talentList?.nodes.count {
                            for index in 0 ..< nodesCount {
                                self.talentList?.nodes.forEach { item in
                                    if let nodeID = item.nodeId,
                                       let titleLabel = self.talentArray[index].titleLabel?.text,
                                       let itemHasNode = item.hasNode,
                                       "\(nodeID)" == titleLabel {
                                        // 如果資料庫中的節點ID對應上畫面中天賦ID，則會把天賦ID的是否點過值接起來，並且將上個節點值放入dicionary中[節點ID: 上個節點ID]
                                        self.talentArray[index].isSelected = itemHasNode
                                        // 因為上個節點有可能是nil
                                        if let lastNode = item.lastNode {
                                            self.talentDictionary["\(nodeID)"] = "\(lastNode)"
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                print(error)
                }
            }
        }
    }
// MARK: - 發送使用者學習的天賦API
    private func postUserGetTalent(nodeld: Int, talentPoint: Int) {
        let userID = self.userDefault.value(forKey: "userID") as? Int
        let parameters = [
            "userId": userID,
            "nodeId": nodeld,
            "talentPoint": talentPoint
        ]
        Server.shared.requestPost(path: "/Talent/Add", parameters: parameters) { response in
            switch response {
            case let .success(data):
                print(data)
                print("成功習得天賦")
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
// MARK: - 是否真的要學習此天賦的alert
    private func alertToCheckLearn(button: UIButton) {
        let alert = UIAlertController(title: "提醒", message: "是否要學習此天賦！", preferredStyle: .alert)
        // 如果確認要學習的話
        let okButton = UIAlertAction(title: "確認", style: .default) { _ in
            button.isSelected = true
            if let talentString = button.titleLabel?.text,
               let talentID = Int(talentString),
               let talentPointInt = self.talentPointInt {
                print("此天賦ID為\(talentString)")
                self.talentPointInt = talentPointInt - 1
                self.talentPoint.text = "\(talentPointInt - 1)"
                self.postUserGetTalent(nodeld: talentID, talentPoint: talentPointInt - 1)
            }
        }
        alert.addAction(okButton)
        // 如果沒有要學習的話
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
// MARK: - 天賦點數不足警告
    private func alertToNotEnoughTalent() {
        let alert = UIAlertController(title: "錯誤", message: "天賦點數不足", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
// MARK: - 請先將前面點完的alert
    private func alertToNotLearn() {
        let alert = UIAlertController(title: "錯誤", message: "請先習得前面天賦", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}
extension AchievementViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
