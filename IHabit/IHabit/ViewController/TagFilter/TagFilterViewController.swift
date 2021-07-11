//
//  TagFilterViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/16.
//

import UIKit
protocol TagFilterViewControllerDelegate: AnyObject {
    func receiveTagItems(userChoseTagID: [Int])
}

class TagFilterViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: TagFilterViewControllerDelegate?
//    var tagNames: [String] = []
    var userChoseTagID: [Int] = []
    var userDefault = UserDefaults.standard
    var missionTag: [TagListData] = []
    // 讓使用者如果點選超過一個的cell暫存位置
    var tagIDTemp: Int?

    @IBAction private func backHome(_ sender: Any) {
        delegate?.receiveTagItems(userChoseTagID: userChoseTagID)
        // 存進userDefault中
        userDefault.setValue(userChoseTagID, forKey: "userChoseTag")
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        // 拿資料
        getTagData()
        // 讓存進去的標籤顯示
//        if let temp = userDefault.value(forKey: "tagNameItems") as? [String] {
//            self.tagNames = temp
//        }
        // 讓之前如果有選的標籤前面圈圈變成實心
        if let temp = userDefault.value(forKey: "userChoseTag") as? [Int] {
            self.userChoseTagID = temp
        }
    }
    // MARK: - 從後端拿標籤資料
    private func getTagData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            Server.shared.requestGet(path: "/GetTagList/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let tagList = try JSONDecoder().decode([TagListData].self, from: data)
                        self.missionTag = tagList
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
    // MARK: - 警告視窗
    private func arrIsFull() {
        let alert = UIAlertController(title: "標籤選項已滿", message: "標籤最多只能選擇一個", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}

extension TagFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        missionTag.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionTag") as? MissionFilterTagTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.cellID = missionTag[indexPath.row].tagId
        cell.tagName.text = missionTag[indexPath.row].tagName

        for tagID in userChoseTagID {
            if missionTag[indexPath.row].tagId == tagID {
                cell.tagIsChoseButton.isSelected = true
            }
        }
        if let tagIDTemp = tagIDTemp, tagIDTemp == missionTag[indexPath.row].tagId {
            cell.tagIsChoseButton.isSelected = false
        }
        return cell
    }
}
// MARK: - 處理Cell的delegate
extension TagFilterViewController: MissionFilterTagTableViewCellDelegate {
    func receiveTagName(tagID: Int, tagIsCancel: Bool) {
        if tagIsCancel {
            if userChoseTagID.count == 1 {
                arrIsFull()
                tagIDTemp = tagID
                tableView.reloadData()
            } else {
                userChoseTagID.append(tagID)
            }
        } else {
            userChoseTagID.removeFirst()
        }
    }
}
