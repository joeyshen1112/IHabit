//
//  SkillViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/7/1.
//

import UIKit

protocol SkillViewControllerDelegate: AnyObject {
    func receiveSkillInfo(whichSelect: Int)
}

class SkillViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: SkillViewControllerDelegate?
    var userDefault = UserDefaults.standard
    var userActorInfo: UserInformationData?
    var careerInt: Int?
    // 技能圖陣列
    var skillArray: [UIImage] = []
    var archerSkillName: [String] = ["百步穿楊", "箭雨", "閃電箭"]
    var magicSkillName: [String] = ["雷擊術", "祕法超載", "隕石術"]
    var warriorSkillName: [String] = ["乞丐大劍", "石化皮膚", "振奮之吼"]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserData()
    }
    // 透過api知道角色的職業是什麼
    private func getUserData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        let email = userDefault.value(forKey: "email") as? String
        if let userID = userID,
           let email = email {
            let parameters = [
                "userId": userID,
                "email": email
            ] as [String: Any]
            Server.shared.requestPost(path: "/User/Info", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let userActorInfo = try JSONDecoder().decode(UserInformationData.self, from: data)
                        self.userActorInfo = userActorInfo
                        if let career = self.userActorInfo?.career {
                            switch career {
                            case "弓箭手":
                                self.careerInt = 1
                                for index in 0 ..< 3 {
                                    if let image = UIImage(named: "archerskill\(index + 1)") {
                                        self.skillArray.append(image)
                                    }
                                }
                            case "法師":
                                self.careerInt = 2
                                for index in 0 ..< 3 {
                                    if let image = UIImage(named: "magicskill\(index + 1)") {
                                        self.skillArray.append(image)
                                    }
                                }
                            case "戰士":
                                self.careerInt = 3
                                for index in 0 ..< 3 {
                                    if let image = UIImage(named: "warriorskill\(index + 1)") {
                                        self.skillArray.append(image)
                                    }
                                }
                            default:
                                print("error")
                            }
                            self.collectionView.reloadData()
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
}
extension SkillViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 告訴外面選了0,1,2哪一招技能
        self.delegate?.receiveSkillInfo(whichSelect: indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "skillCell", for: indexPath) as? SkillCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.skillButton.isEnabled = false
        // 設定圖片
        if self.skillArray.count >= 3 {
            cell.skillButton.setBackgroundImage(self.skillArray[indexPath.row], for: .normal)
        }
        // 設定技能文字與技能內容(1：弓箭手,2：法師,3：戰士)
        switch self.careerInt {
        case 1:
            cell.skillName.text = archerSkillName[indexPath.row]
        case 2:
            cell.skillName.text = magicSkillName[indexPath.row]
        case 3:
            cell.skillName.text = warriorSkillName[indexPath.row]
        default:
            print("error")
        }
        return cell
    }
}
