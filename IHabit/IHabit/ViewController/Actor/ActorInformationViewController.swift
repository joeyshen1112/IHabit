//
//  ActorInformationViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/18.
//

import UIKit

class ActorInformationViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var helmetImage: UIImageView!
    @IBOutlet weak var weaponImage: UIImageView!
    @IBOutlet weak var pantsImage: UIImageView!
    @IBOutlet weak var armorImage: UIImageView!
    @IBOutlet weak var shieldImage: UIImageView!
    @IBOutlet weak var accImage: UIImageView!
    @IBOutlet weak var actorImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var careerName: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var userName: UILabel!

    // 角色素質
    var userInfoData: UserInformationData?
    // 角色裝備
    var userEquip: UserEquipData?
    var userDefault = UserDefaults.standard
    // 素質icon陣列
    let qualityImageList = [ "actor_health", "actor_magic", "actor_attack", "actor_defense", "actor_experience", "actor_Coin"]
    // 素質detailTitle陣列
    let qualityDetailList = [ "最大生命值：", "最大魔力值：", "總傷害：", "總防禦：", "經驗獲取加成：", "金錢獲取加成："]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getActorData()
    }
    // 選擇稱號
    @IBAction private func choseTitle(_ sender: Any) {
        // 跑出view
        performSegue(withIdentifier: "showTitle", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTitle" {
            let titleVC = segue.destination as? ActorTitleViewController
            titleVC?.titleNow = self.titleName.text
            titleVC?.delegate = self
            print("現在稱號是\(titleVC?.titleNow)")
            if let titleVC = titleVC {
                titleVC.preferredContentSize = CGSize(width: 180, height: 300)
                let titleViewController = titleVC.popoverPresentationController
                if let titleViewController = titleViewController {
                    titleViewController.delegate = self
                }
            }
        }
    }
    // 視窗化
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    // MARK: - 拿去會員角色素質以及裝備兩個API
    private func getActorData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        let email = userDefault.value(forKey: "email") as? String
        if let userID = userID, let email = email {
            // 角色圖片
            Server.shared.requestGet(path: "/UserEquip/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let userEquip = try JSONDecoder().decode(UserEquipData.self, from: data)
                        self.userEquip = userEquip
                        if let userProps = self.userEquip?.userProps {
                            for item in userProps {
                                if item.type != nil,
                                   let icon = item.icon {
                                    switch item.type {
                                    case 1:
                                        self.helmetImage.image = UIImage(named: "\(icon)")
                                    case 2:
                                        self.accImage.image = UIImage(named: "\(icon)")
                                    case 3:
                                        self.armorImage.image = UIImage(named: "\(icon)")
                                    case 4:
                                        self.shieldImage.image = UIImage(named: "\(icon)")
                                    case 5:
                                        self.pantsImage.image = UIImage(named: "\(icon)")
                                    case 6:
                                        self.weaponImage.image = UIImage(named: "\(icon)")
                                    default:
                                        print("error")
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
            // 角色素質
            let parameters = [
                "userId": userID,
                "email": email
            ] as [String: Any]

            Server.shared.requestPost(path: "/User/Info", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let userInfo = try JSONDecoder().decode(UserInformationData.self, from: data)
                        self.userInfoData = userInfo
                        // actorImage是指職業圖
                        if let actorImage = userInfo.career,
                           let level = userInfo.level,
                           let userName = userInfo.name {
                            self.userName.text = userName
                            self.careerName.text = actorImage
                            self.level.text = "\(level)"
                            self.changeActorIcon(actorHead: actorImage)
                            // 稱號判斷
                            if let titleName = userInfo.title {
                                self.titleName.text = titleName
                            } else {
                                // 如果角色一開始沒有稱號的話
                                self.titleName.text = "初出茅廬"
                            }
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
    // 切換職業圖像
    private func changeActorIcon(actorHead: String) {
        switch actorHead {
        case "弓箭手":
            self.actorImage.image = UIImage.animatedImageNamed("archerIDLE", duration: 1)
        case "法師":
            self.actorImage.image = UIImage.animatedImageNamed("MageIDLE", duration: 1)
        case "戰士":
            self.actorImage.image = UIImage.animatedImageNamed("warriorIDLE", duration: 1)
        default:
            print("error")
        }
    }
}
extension ActorInformationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        qualityImageList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActorInfoCell") as? ActorInfoTableViewCell else {
            return UITableViewCell()
        }
        cell.infoImage.image = UIImage(named: self.qualityImageList[indexPath.row])
        cell.infoDetail.text = self.qualityDetailList[indexPath.row]

        if let userInfoData = userInfoData,
           let hp = userInfoData.hp,
           let magic = userInfoData.magic,
           let atk = userInfoData.atk,
           let def = userInfoData.def,
           let coin = userInfoData.moneyPlus,
           let exp = userInfoData.expPlus {
            switch indexPath.row {
            case 0:
                cell.infoDetailData.text = "\(hp)"
            case 1:
                cell.infoDetailData.text = "\(magic)"
            case 2:
                cell.infoDetailData.text = "\(atk)"
            case 3:
                cell.infoDetailData.text = "\(def)"
            case 4:
                cell.infoDetailData.text = "\(coin)"
            case 5:
                cell.infoDetailData.text = "\(exp)"
            default:
                print("error")
            }
        }
        return cell
    }
}
// 稱號的Delegate
extension ActorInformationViewController: ActorTitleViewControllerDelegate {
    func receiveTitleName(titleName: String) {
        self.titleName.text = titleName
    }
}
