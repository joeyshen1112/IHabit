//
//  HomeViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/6.
//

import UIKit

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var iconToMissionOverView: UIImageView!
    @IBOutlet weak var iconToStore: UIImageView!
    @IBOutlet weak var iconToFight: UIImageView!
    @IBOutlet weak var iconToChangeHome: UIButton!
    @IBOutlet weak var actorInformationViewController: UIImageView!
    @IBOutlet weak var missionListViewController: UIView!
    // 動態的
    @IBOutlet weak var backgroundImage: UIImageView!
    // 靜態的
    @IBOutlet weak var backgroundHomeImage: UIImageView!
    @IBOutlet weak var firePlaceImage: UIImageView!
    @IBOutlet weak var expProgressView: UIProgressView!
    @IBOutlet weak var actorImage: UIImageView!
    // 角色等級
    @IBOutlet weak var actorLevel: UILabel!
    @IBOutlet weak var actorFeel: UIImageView!
    var userDefault = UserDefaults.standard
    var actorCareer: String?
    // 戰鬥level選擇VC
    var fightVC: FightViewController?
    var missionOverViewVC: MissionOverviewViewController?
    var actorInformationVC: ActorInformationViewController?
    var storeVC: StoreViewController?
    var missionListVC: MissionListViewController?
    var userChoseTag: [String] = []
    // 表情符號的計時器
    var time: Timer?
    var count = 0
    var complete = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        self.actorFeel.isHidden = true
        self.actorFeel.image = UIImage.animatedImageNamed("feelLove", duration: 0.5)
        self.backgroundHomeImage.isHidden = true
        self.firePlaceImage.isHidden = true
        self.firePlaceImage.image = UIImage.animatedImageNamed("FirePlace", duration: 1)
        // 設定一開始在戶外，所以圖片要以home
        self.iconToChangeHome.setBackgroundImage(UIImage(named: "homeIcon"), for: .normal)
        self.iconToChangeHome.setBackgroundImage(UIImage(named: "outSide"), for: .selected)
        self.expProgressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.2)
        // 設計背景GIF
        setBackgroundAnimator()
        setupChildViewControllers()
        // 每次登入這個主畫面，把使用者之前標籤的紀錄清空
        self.userDefault.setValue(userChoseTag, forKey: "userChoseTag")
        // 前往習慣總覽
        iconToMissionOverView.isUserInteractionEnabled = true
        let myImageTouchToMissionOverView = UITapGestureRecognizer(target: self, action: #selector(iconToMissionOverViewTouch))
        iconToMissionOverView.addGestureRecognizer(myImageTouchToMissionOverView)
        // 前往商店
        iconToStore.isUserInteractionEnabled = true
        let myImageTouchToStroeView = UITapGestureRecognizer(target: self, action: #selector(iconToStoreViewTouch))
        iconToStore.addGestureRecognizer(myImageTouchToStroeView)
        // 前往戰鬥
        iconToFight.isUserInteractionEnabled = true
        let myImageTouchToFightView = UITapGestureRecognizer(target: self, action: #selector(iconToFightViewTouch))
        iconToFight.addGestureRecognizer(myImageTouchToFightView)
        // 前往角色
        actorInformationViewController.isUserInteractionEnabled = true
        let myImageTouch2 = UITapGestureRecognizer(target: self, action: #selector(iconToActorViewTouch))
        actorInformationViewController.addGestureRecognizer(myImageTouch2)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        getUserData()
    }

    // 切換家裡或是戶外的按鈕
    @IBAction private func iconToHomeAction(_ sender: Any) {
        self.iconToChangeHome.isSelected.toggle()
        if self.iconToChangeHome.isSelected {
            // 變室內
            if let actorCareer = self.actorCareer {
                self.changeActorStandIcon(actorHead: actorCareer)
            }
            self.backgroundImage.isHidden = true
            self.firePlaceImage.isHidden = false
            self.backgroundHomeImage.isHidden = false
        } else {
            // 變戶外
            if let actorCareer = self.actorCareer {
                self.changeActorIcon(actorHead: actorCareer)
            }
            self.backgroundImage.isHidden = false
            self.firePlaceImage.isHidden = true
            self.backgroundHomeImage.isHidden = true
        }
    }
    // 拿取使用者資料
    private func getUserData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        let email = userDefault.value(forKey: "email") as? String
        if let userID = userID, let email = email {
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
                        // 設定角色資訊
                        if let actorHead = userInfo.career,
                           let level = userInfo.level,
                           let exp = userInfo.exp {
                            // 角色職業
                            self.actorCareer = actorHead
                            // 職業頭像
                            self.changeActorIcon(actorHead: actorHead)
                            // 等級顯示
                            self.actorLevel.text = "\(level)"
                            // 當前經驗值
                            self.expProgressView.progress = Float(exp) / Float(100)
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

    // 切換職業大頭貼(動態背景)
    private func changeActorIcon(actorHead: String) {
        switch actorHead {
        case "弓箭手":
            self.actorInformationViewController.image = UIImage(named: "Mirror_RangerHead_Image")
            self.actorImage.image = UIImage.animatedImageNamed("ArcherWALK", duration: 1)
        case "法師":
            self.actorInformationViewController.image = UIImage(named: "HEALER_HEAD")
            self.actorImage.image = UIImage.animatedImageNamed("MageWALK", duration: 1)
        case "戰士":
            self.actorInformationViewController.image = UIImage(named: "BERZERKER_HEAD")
            self.actorImage.image = UIImage.animatedImageNamed("WALK", duration: 1)
        default:
            print("error")
        }
    }
    // 切換職業大頭貼(靜態背景)
    private func changeActorStandIcon(actorHead: String) {
        switch actorHead {
        case "弓箭手":
            self.actorInformationViewController.image = UIImage(named: "Mirror_RangerHead_Image")
            self.actorImage.image = UIImage.animatedImageNamed("archerIDLE", duration: 1)
        case "法師":
            self.actorInformationViewController.image = UIImage(named: "HEALER_HEAD")
            self.actorImage.image = UIImage.animatedImageNamed("MageIDLE", duration: 1)
        case "戰士":
            self.actorInformationViewController.image = UIImage(named: "BERZERKER_HEAD")
            self.actorImage.image = UIImage.animatedImageNamed("warriorIDLE", duration: 1)
        default:
            print("error")
        }
    }
    // 切換戰鬥場景等級的segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選擇怪物的pop
        if segue.identifier == "showFightLevel" {
            let fightLevelVC = segue.destination as? ChoseLevelFightViewController
            if let fightLevelVC = fightLevelVC {
                fightLevelVC.delegate = self
                fightLevelVC.preferredContentSize = CGSize(width: 400, height: 400)
                let fightLevelController = fightLevelVC.popoverPresentationController
                if let fightLevelController = fightLevelController {
                    fightLevelController.delegate = self
                }
            }
            // 等級提升的pop
        } else if segue.identifier == "levelUp" {
            let levelUpVC = segue.destination as? LevelUpViewController
            if let levelUpVC = levelUpVC {
                levelUpVC.preferredContentSize = CGSize(width: 350, height: 180)
                let levelUpVCController = levelUpVC.popoverPresentationController
                if let levelUpVCController = levelUpVCController {
                    levelUpVCController.delegate = self
                }
            }
        }
    }
    // 讓popover非全螢幕
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    // 點擊icon切換選擇戰鬥Level場景
    @objc
    private func iconToFightViewTouch() {
        performSegue(withIdentifier: "showFightLevel", sender: nil)
    }
    // 點擊iocn任務總覽進去的func
    @objc
    private func iconToMissionOverViewTouch() {
        let storyboard = UIStoryboard(name: "MissionOverview", bundle: nil)
        self.missionOverViewVC = storyboard.instantiateViewController(identifier: "MissionOverviewViewController") as? MissionOverviewViewController
        if let missionOverviewVC = missionOverViewVC {
            navigationController?.pushViewController(missionOverviewVC, animated: true)
        }
    }
    // 點擊切換商店頁面
    @objc
    private func iconToStoreViewTouch() {
        let storyboard = UIStoryboard(name: "Store", bundle: nil)
        self.storeVC = storyboard.instantiateViewController(identifier: "StoreViewController") as? StoreViewController
        if let storeVC = storeVC {
            navigationController?.pushViewController(storeVC, animated: true)
        }
    }
    // 點擊iocn角色進去的func
    @objc
    private func iconToActorViewTouch() {
        let storyboard = UIStoryboard(name: "ActorInformation", bundle: nil)
        self.actorInformationVC = storyboard.instantiateViewController(identifier: "ActorInformationViewController") as? ActorInformationViewController
        if let actorInformationVC = actorInformationVC {
            navigationController?.pushViewController(actorInformationVC, animated: true)
        }
    }
    // 設定container View的內容
    private func setupChildViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let missionListVC = storyboard.instantiateViewController(identifier: "MissionListViewController") as? MissionListViewController
        if let missionListVC = missionListVC {
            addChild(childController: missionListVC, to: missionListViewController)
        }
        // 將使用者所選擇的filter傳進去containerView中
        self.missionListVC = missionListVC
        self.missionListVC?.delegate = self
    }
    private func setBackgroundAnimator() {
        guard let data = NSDataAsset(name: "actorBackground")?.data else {
            return
        }
        let cfData = data as CFData
        CGAnimateImageDataWithBlock(cfData, nil) { _, cgImage, _ in
            self.backgroundImage.image = UIImage(cgImage: cgImage)
        }
    }
}
// MARK: - 處理完成任務的delegate
extension HomeViewController: MissionListViewControllerDelegate {
    func finishHabitget(finishHabitGet: FinishHabit) {
        if let level = finishHabitGet.level,
           let exp = finishHabitGet.exp {
            // 如果等級比之前紀錄還高，就跳通知升等了
            if let actorLevel = self.actorLevel.text,
               let levelBefore = Int(actorLevel),
               level > levelBefore {
                performSegue(withIdentifier: "levelUp", sender: nil)
            }
            self.actorLevel.text = "\(level)"
            self.expProgressView.progress = Float(exp) / Float(100)
            self.actorFeel.isHidden = false
            time = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(timeToFeel(sender:)), userInfo: nil, repeats: true)
        }
    }
    // 出現表情的計時器
    @objc
    private func timeToFeel(sender: Timer) {
        count += 10
        // 如果進度完成
        if count >= complete {
            count = 0
            time?.invalidate()
            time = nil
            // 要做的內容
            self.actorFeel.isHidden = true
        }
    }
}
// MARK: - 處理選擇戰鬥等級的delegate
extension HomeViewController: ChoseLevelFightViewControllerDelegate {
    func changeView(level: Int) {
        let storyboard = UIStoryboard(name: "Fight", bundle: nil)
        self.fightVC = storyboard.instantiateViewController(identifier: "FightViewController") as? FightViewController
        // 將怪物等級傳到戰鬥頁面
        self.fightVC?.bossLevel = level
        if let fightVC = fightVC {
            navigationController?.pushViewController(fightVC, animated: true)
        }
    }
}
