//
//  MissionBaseSetViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/10.
//

import UIKit
protocol MissionSetTagViewControllerDelegate: AnyObject {
    func receiveTagName(tagId: [Int])
}

class MissionSetTagViewController: UIViewController {
    @IBOutlet weak var baseSetCollectionView: UICollectionView!
    weak var delegate: MissionSetTagViewControllerDelegate?
    let userDefault = UserDefaults.standard
    var tagIdArray: [Int] = []
    var missionTag: [TagListData] = []
    var userChoseTag: Int?
    // 編輯狀態
    var editTagID: [Int] = []
    var isEditMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        baseSetCollectionView.delegate = self
        baseSetCollectionView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getTagData()
    }
}

extension MissionSetTagViewController: UICollectionViewDelegate, UICollectionViewDataSource, MissionTagViewControllerDelegate {
    // 將勾選的tag呈現在這個view中，並且透過delegate傳遞給新建任務的頁面
    func getTagNameItems(tagId: [Int]) {
        self.tagIdArray = tagId
        self.getTagData()
        self.delegate?.receiveTagName(tagId: self.tagIdArray)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 切換至新增Tag的頁面
        if indexPath.row == 0 {
            let missionTagView = storyboard?.instantiateViewController(identifier: "MissionTagViewController") as? MissionTagViewController
            if let missionTagView = missionTagView {
                missionTagView.delegate = self
                present(missionTagView, animated: true, completion: nil)
                tagIdArray = []
            }
        // 刪除視窗跳出來
        } else {
            userChoseTag = missionTag[indexPath.row - 1].tagId
            removeTagAlert()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        missionTag.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? MissionTagCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.tagName.text = "➕"
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? MissionTagCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.tagName.text = missionTag[indexPath.row - 1].tagName
        return cell
    }
// MARK: - 取得Tag資料
    private func getTagData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            Server.shared.requestGet(path: "/GetTagList/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    do {
                        let tagList = try JSONDecoder().decode([TagListData].self, from: data)
                        var tempList: [TagListData] = []
                        self.missionTag = tagList

                        if self.isEditMode, !self.editTagID.isEmpty {
                            print("!!!!!")
                            self.editTagID.forEach { index in
                                for item in self.missionTag {
                                    if item.tagId == index {
                                        tempList.append(item)
                                    }
                                }
                            }
                            self.missionTag = tempList
                            self.editTagID.removeAll()
                            self.isEditing.toggle()
                        } else {
                            print("~~~~~")
                            self.tagIdArray.forEach { index in
                                for item in self.missionTag {
                                    if item.tagId == index {
                                        tempList.append(item)
                                    }
                                }
                            }
                            self.missionTag = tempList
                        }
                        self.baseSetCollectionView.reloadData()
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
// MARK: - 刪除Tag的alert視窗
    private func removeTagAlert() {
        let removeTagAlert = UIAlertController(title: "是否要刪除這個Tag", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        removeTagAlert.addAction(cancelAction)
        let okAction = UIAlertAction(title: "刪除", style: .destructive) { _ -> Void in
            // 刪除的時候也必須要傳遞delegate給外面主頁面做更新
            if let index = self.userChoseTag {
                self.missionTag.removeAll { $0.tagId == index }
                var tempIndex: [Int] = []
                self.missionTag.forEach { item in
                    if let tagId = item.tagId {
                        tempIndex.append(tagId)
                    }
                }
                self.delegate?.receiveTagName(tagId: tempIndex)
                self.baseSetCollectionView.reloadData()
            }
        }
        removeTagAlert.addAction(okAction)
        present(removeTagAlert, animated: true, completion: nil)
    }
}
