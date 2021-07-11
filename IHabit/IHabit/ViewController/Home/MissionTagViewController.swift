//
//  MissionTagViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/9.
//

import UIKit

// 讓被委任的view可以拿到這邊所點擊的tag
protocol MissionTagViewControllerDelegate: AnyObject {
    func getTagNameItems(tagId: [Int])
}

class MissionTagViewController: UIViewController {
    weak var delegate: MissionTagViewControllerDelegate?
    // Tag的部分
    var missionTag: [TagListData] = []
    var tagNameItemsForNextPage: [Int] = []
    var tagNameItemsForNextPageIsFull = false
    var tagName: String?
    // 讓使用者如果點選超過一個的cell暫存位置
    var tagTemp: Int?
//    var tagNameFromBaseView: [String] = []
    var userDefault = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    var isDataChange = false {
        didSet {
            self.getTagData()
        }
    }

    // 完成Tag的選擇，並傳給外面的頁面
    @IBAction private func doneActionButton(_ sender: Any) {
        delegate?.getTagNameItems(tagId: tagNameItemsForNextPage)
        dismiss(animated: true, completion: nil)
    }

    // 新建新的Tag
    @IBAction private func addNewTagButton(_ sender: Any) {
        let addNewTagAlert = UIAlertController(title: "建立新的標籤", message: nil, preferredStyle: .alert)
        addNewTagAlert.addTextField { (textField: UITextField?) -> Void in
            textField?.placeholder = "請輸入標籤名"
        }
        // 取消按鈕
        let alertCancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        addNewTagAlert.addAction(alertCancelButton)
        // 確認按鈕＆若輸入的內容不為“”則將存入tagName陣列中
        let alertOKButton = UIAlertAction(title: "確認", style: .default) { _ in
            if let text = addNewTagAlert.textFields?[0].text, !text.isEmpty {
                self.tagName = text
                self.addNewTagData()
                self.tableView.reloadData()
            }
        }
        addNewTagAlert.addAction(alertOKButton)
        self.present(addNewTagAlert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getTagData()
    }
// MARK: - 跟後端拿取Tag資料
    private func getTagData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            Server.shared.requestGet(path: "/GetTagList/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    do {
                        let tagList = try JSONDecoder().decode([TagListData].self, from: data)
                        self.missionTag = tagList
                        self.tableView.reloadData()
                    } catch {
                        print(error.localizedDescription)
                    }
                    print(data)
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    // MARK: - 告訴後端新增Tag資料，每次增加都要重新拿一次資料
    private func addNewTagData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID, let tagName = self.tagName {
            let parameters = [
                "tagName": tagName,
                "userId": userID
            ] as [String: Any]

            Server.shared.requestPost(path: "/AddTag", parameters: parameters) { response in
                self.isDataChange = true
                switch response {
                case let .success(data):
                    print(data)
                    self.getTagData()
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    // MARK: - 告訴後端刪除Tag資料，每次刪除都要重新拿一次資料
    private func removeTagData(tagId: Int) {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            let parameters = [
                "userId": userID,
                "tagId": tagId
            ] as [String: Any]
            Server.shared.requestPut(path: "/CloseTag", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print("=====")
                    print(data)
                case let .failure(error):
                    print(error.localizedDescription)
                }
                print("$$$$$$")
                self.isDataChange = true
            }
        }
    }
// MARK: - 離開頁面過程中，會將全部『標籤』資料存進UserDefault中
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
extension MissionTagViewController: UITableViewDelegate, UITableViewDataSource, MissionTagTableViewCellDelegate {
    // 從tableViewCell拿到被點擊的tag
    func receiveTagName(tagData: Int, tagIsChose: Bool) {
        if tagIsChose {
            // 如果標籤陣列長度達到3個，則不能再加入
            if tagNameItemsForNextPage.count == 3 {
                arrIsFull()
                tagTemp = tagData
                tableView.reloadData()
            } else {
                tagNameItemsForNextPage.append(tagData)
            }
        } else {
            tagNameItemsForNextPage.removeAll { $0 == tagData
            }
        }
    }
    // 刪除的func，如果是預設的前四個則會跳出通知無法刪除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let isDefault = missionTag[indexPath.row].isDefault, isDefault == true else {
            if let tagId = missionTag[indexPath.row].tagId {
                self.removeTagData(tagId: tagId)
            }
//            self.getTagData()
//            tableView.deleteRows(at: [indexPath], with: .fade)
            return
        }
        let alertControler = UIAlertController(title: "錯誤", message: "這是預設的標籤，無法刪除", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertControler.addAction(okAction)
        self.present(alertControler, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missionTag.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionTag") as? MissionTagTableViewCell else {
            return UITableViewCell()
        }
        if let tagTemp = tagTemp, tagTemp == missionTag[indexPath.row].tagId {
            cell.tagIsChoseButton.isSelected = false
        }
        cell.delegate = self
        cell.tagID = missionTag[indexPath.row].tagId
        cell.tagName.text = missionTag[indexPath.row].tagName
        return cell
    }
// MARK: - 警告視窗
    private func arrIsFull() {
        let alert = UIAlertController(title: "標籤選項已滿", message: "標籤最多只能選擇三個", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}
