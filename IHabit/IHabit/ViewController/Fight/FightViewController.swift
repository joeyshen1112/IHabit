//
//  FightViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/30.
//

import UIKit

// swiftlint:disable type_body_length
class FightViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bossHealth: UIProgressView!
    @IBOutlet weak var actorHealth: UIProgressView!
    @IBOutlet weak var actorMagicProgress: UIProgressView!
    // 怪物血量
    @IBOutlet weak var bossHealthLabel: UILabel!
    // 怪物圖片
    @IBOutlet weak var bossImage: UIImageView!
    // 怪物被攻擊Gif
    @IBOutlet weak var attackGifImage: UIImageView!
    // 角色血量
    @IBOutlet weak var actorHealthLabel: UILabel!
    // 角色魔力
    @IBOutlet weak var actorMagicLabel: UILabel!
    @IBOutlet weak var actorAttack: UIButton!
    @IBOutlet weak var actorSkill: UIButton!
    @IBOutlet weak var actorMedicine: UIButton!
    // 誰的回合圖示
    @IBOutlet weak var whoTrunImage: UIImageView!
    @IBOutlet weak var whoTurnLabel: UILabel!
    // 藥品剩餘量Label
    @IBOutlet weak var medicineCountLabel: UILabel!
    @IBOutlet weak var monsterAttackImage: UIImageView!
    @IBOutlet weak var unFightBackground: UIImageView!
    // true代表玩家回合，false代表怪物回合
    var actorTurn = true
    // 怪物資訊
    var monsterID: Int?
    var bossInfo: BossInfoData?
    var userDefault = UserDefaults.standard
    var bossHp = 0
    var bossStartHp = 0
    // 怪物攻擊系列
    var bosslightAttack: Int?
    var bossNormalAttack: Int?
    var bossCriticalStrike: Int?
    var bossAttackArray: [Int] = []
    // 使用者角色資訊
    var userActorInfo: UserInformationData?
    // 角色血量
    var actorHp = 0
    var actorStartHp = 0
    var actorMagic = 0
    var actorStartMagic = 0
    // 角色職業
    var careerString: String?
    // 角色攻擊力
    var actorAtk = 0
    // 角色防禦力
    var actorDef = 0
    // boss的等級
    var bossLevel: Int?
    // 下方message訊息區
    var messageArray: [String] = []
    var whoTrunArray: [Bool] = []
    // 攻擊動畫計時用
    var myTimerToNormalAttackAnimated: Timer?
    // 補血計時用
    var myTimerToRecovery: Timer?
    // 怪物回合計時用
    var monsterAttack: Timer?
    // 切換角色用
    var characterChange: Timer?
    // 分段攻擊用
    var skillAttackChange: Timer?
    var ActorCount = 0
    var MonsterCount = 0
    var characterCount = 0
    var skillAttack = 0
    var complete = 100
    // 秘法超載int
    var magicOverload = 1
    // 麻痺回合count
    var paralysisCount = 0
    // 戰士使用回血技能的Bool
    var warriorRecovery = false
    // 戰士提升防禦回合數
    var warriorDefUp = 0
    // 回血道具
    var medicineCount = 3
    // 已選技能欄暫存
    var skillTemp: Int?
    // 獲勝得資料(金錢)
    var money = 0

    // 攻擊動作
    @IBAction private func actorAttackAction(_ sender: Any) {
        self.unFightBackground.isHidden = true
        if self.actorTurn {
            // 回合基本流程
            self.baseProcess()
            // 攻擊動畫
            self.attackGifImage.isHidden = false
            // 一般攻擊的計時器，等動畫完成才扣血
            myTimerToNormalAttackAnimated = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countDownToNormalAttack(sender: )), userInfo: nil, repeats: true)

            // 計時開始，換怪物攻擊
            monsterAttack = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countDown(sender: )), userInfo: nil, repeats: true)
        }
    }
    // 技能動作
    @IBAction private func actorSkillAction(_ sender: Any) {
        if self.actorTurn {
            // 跑出選擇技能的view
            performSegue(withIdentifier: "showSkill", sender: nil)
            // 實際執行的內容應該會顯示在receiveSkillInfo這個回傳的delegate func中
        }
    }
    // 使用藥品
    @IBAction private func actorMedicineAction(_ sender: Any) {
        self.unFightBackground.isHidden = true
        if self.actorTurn {
            // 回合基本流程
            self.baseProcess()
            // 回血的計時器
            myTimerToRecovery = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countRecovery), userInfo: nil, repeats: true)

            // 計時開始，換怪物攻擊
            monsterAttack = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countDown(sender: )), userInfo: nil, repeats: true)
        }
        // 如果藥品使用次數小於等於0
        if self.medicineCount <= 0 {
            self.actorMedicine.isEnabled = false
        }
    }

    // 彈出技能視窗
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSkill" {
            let skillVC = segue.destination as? SkillViewController
            if let skillVC = skillVC {
                skillVC.preferredContentSize = CGSize(width: 360, height: 170)
                skillVC.delegate = self
                let skillViewController = skillVC.popoverPresentationController
                if let skillViewController = skillViewController {
                    skillViewController.delegate = self
                }
            }
        }
    }
    // 視窗化
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.bossHealth.transform = CGAffineTransform(scaleX: 1.0, y: 5)
        self.actorHealth.transform = CGAffineTransform(scaleX: 1.0, y: 5)
        self.actorMagicProgress.transform = CGAffineTransform(scaleX: 1.0, y: 5)
        self.monsterAttackImage.image = UIImage(named: "scratch1")
        self.monsterAttackImage.isHidden = true
        setBackgroundAnimator()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.attackGifImage.isHidden = true
        self.medicineCountLabel.text = "3"
        self.whoTrunImage.image = UIImage(named: "messageFightIcon")
        self.whoTurnLabel.text = "你的回合"
        self.unFightBackground.image = UIImage(named: "readyToFight")
        getActorInfo()
        getBossInfo()
    }
// MARK: - 拿取怪物資訊
    private func getBossInfo() {
        if let bossLevel = self.bossLevel {
            Server.shared.requestGet(path: "/MonsterInfo/\(bossLevel)", parameters: nil) { [self] response in
                switch response {
                case let .success(data):
                    print(data)
                    // 將怪物資訊下載下來
                    do {
                        let bossInfo = try JSONDecoder().decode(BossInfoData.self, from: data)
                        self.bossInfo = bossInfo
                        // 讀取怪物資訊顯示在畫面上
                        if let bossHealth = self.bossInfo?.hp,
                           let bossImage = self.bossInfo?.icon,
                           let lightAttack = self.bossInfo?.lightAttack,
                           let normalAttack = self.bossInfo?.normalAttack,
                           let criticalStrike = self.bossInfo?.criticalStrike,
                           let monsterID = self.bossInfo?.monsterId {
                            self.monsterID = monsterID
                            self.bossHp = bossHealth
                            self.bossStartHp = bossHealth
                            self.bossHealthLabel.text = "\(bossHealth)/\(bossStartHp)"
                            print("怪物血量\(self.bossHp)")
                            self.bossImage.image = UIImage(named: "\(bossImage)")
                            // 攻擊係數
                            self.bosslightAttack = lightAttack
                            self.bossNormalAttack = normalAttack
                            self.bossCriticalStrike = criticalStrike
                            // 將攻擊係數放盡陣列中
                            self.bossAttackArray.append(lightAttack)
                            self.bossAttackArray.append(normalAttack)
                            self.bossAttackArray.append(criticalStrike)
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
// MARK: - 拿取使用者角色資訊
    private func getActorInfo() {
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
                        if let hp = self.userActorInfo?.hp,
                           let magic = self.userActorInfo?.magic,
                           let atk = self.userActorInfo?.atk,
                           let def = self.userActorInfo?.def,
                           let career = self.userActorInfo?.career {
                            self.careerString = career
                            // 攻擊圖片
                            switch career {
                            case "弓箭手":
                                self.actorAttack.setImage(UIImage(named: "archerattack"), for: .normal)
                            case "法師":
                                self.actorAttack.setImage(UIImage(named: "magicattack"), for: .normal)
                            case "戰士":
                                self.actorAttack.setImage(UIImage(named: "warriorattack"), for: .normal)
                            default:
                                print("error")
                            }
                            self.actorHp = hp
                            self.actorStartHp = hp
                            self.actorHealthLabel.text = "\(hp)/\(self.actorStartHp)"
                            self.actorMagic = magic
                            self.actorStartMagic = magic
                            self.actorMagicLabel.text = "\(magic)/\(self.actorStartMagic)"
                            self.actorDef = def
                            self.actorAtk = atk
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
// MARK: - 角色獲勝
    private func actorWinData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            let parameters = [
                "userId": userID,
                "monsterId": self.monsterID
            ]

            Server.shared.requestPost(path: "/WinGame", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let fightWinData = try JSONDecoder().decode(FightWin.self, from: data)
                        if let money = fightWinData.data {
                            self.money = money
                        }
                        self.bossImage.image = UIImage(named: "fightWin")
                        self.alertToActorWin()
                    } catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    // MARK: - 設計攻擊GIF
    private func setBackgroundAnimator() {
        guard let data = NSDataAsset(name: "attackGif")?.data else {
            return
        }
        let cfData = data as CFData
        CGAnimateImageDataWithBlock(cfData, nil) { _, cgImage, _ in
            self.attackGifImage.image = UIImage(cgImage: cgImage)
        }
    }
    // MARK: - 平移動畫
    private func imageMove() {
        // 怪物左右動攻擊動畫(原先位置為195,134)
        UIView.animate(withDuration: 0.3, animations: {
            self.bossImage.frame = self.bossImage.frame.offsetBy(dx: -70, dy: 0)
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.3, animations: {
                    self.bossImage.frame = self.bossImage.frame.offsetBy(dx: 140, dy: 0)
                }, completion: { done in
                    if done {
                        UIView.animate(withDuration: 0.3) {
                            self.bossImage.frame = self.bossImage.frame.offsetBy(dx: -70, dy: 0)
                        }
                    }
                })
            }
        })
    }
    // MARK: - 攻擊的計時器功能
    @objc
    private func countDownToNormalAttack(sender: Timer) {
        ActorCount += 30
        // 當完成計時
        if ActorCount >= complete {
            // 重設計數器及 Timer 供下次按下按鈕測試
            ActorCount = 0
            myTimerToNormalAttackAnimated?.invalidate()
            myTimerToNormalAttackAnimated = nil

            // 攻擊動畫關掉
            self.attackGifImage.isHidden = true
            // 一般攻擊，怪物血量減掉角色攻擊力
            self.bossHp -= self.actorAtk
            // 怪物血量文字版
            self.bossHealthLabel.text = "\(self.bossHp)/\(self.bossStartHp)"
            // 怪物血量進度條
            self.bossHealth.progress = Float(self.bossHp) / Float(self.bossStartHp)
            // 傳進去下方訊息欄
            self.messageArray.insert("角色對怪物造成了\(self.actorAtk)傷害", at: 0)
            self.whoTrunArray.insert(true, at: 0)

            // 如果怪物血量歸零，挑戰成功
            guard self.bossHp > 0 else {
                self.actorWinData()
                return
            }

            // 要換怪物的部分
            print("玩家回合結束")
            self.whoTrunImage.image = UIImage(named: "messageMonsterIcon")
            self.whoTurnLabel.text = "怪物的回合"
            self.tableView.reloadData()
            self.characterChange = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countToChangeCharacter), userInfo: nil, repeats: true)
        }
    }
    // MARK: - 使用技能的計時器功能
    @objc
    private func countSkillAttack(sender: Timer) {
        ActorCount += 30
        // 當完成計時
        if ActorCount >= complete {
            // 重設計數器及 Timer 供下次按下按鈕測試
            ActorCount = 0
            myTimerToNormalAttackAnimated?.invalidate()
            myTimerToNormalAttackAnimated = nil

            // 攻擊動畫關掉
            self.attackGifImage.isHidden = true
            // 如果戰士使用回血技能，則變true
            if let skillTemp = self.skillTemp {
                switch skillTemp {
                // 弓箭手系列
                case 1:
                    print("百步穿楊")
                    // 一般攻擊，怪物血量減掉角色攻擊力
                    let attack = Float(self.actorAtk) * Float(1.5)
                    self.bossHp -= Int(attack)
                    // 怪物血量文字版
                    self.bossHealthLabel.text = "\(self.bossHp)/\(self.bossStartHp)"
                    // 怪物血量進度條
                    self.bossHealth.progress = Float(self.bossHp) / Float(self.bossStartHp)
                    // 傳進去下方訊息欄
                    self.messageArray.insert("角色使用了[百步穿楊]造成了\(self.actorAtk)*1.5倍傷害", at: 0)
                    self.whoTrunArray.insert(true, at: 0)
                case 2:
                    print("箭雨")
                    // 一般攻擊，怪物血量減掉角色攻擊力
                    let attack = Float(self.actorAtk) * Float(3)
                    self.bossHp -= Int(attack)
                    // 怪物血量文字版
                    self.bossHealthLabel.text = "\(self.bossHp)/\(self.bossStartHp)"
                    // 怪物血量進度條
                    self.bossHealth.progress = Float(self.bossHp) / Float(self.bossStartHp)
                    // 傳進去下方訊息欄
                    self.messageArray.insert("角色使用了[箭雨]造成了3段傷害", at: 0)
                    self.whoTrunArray.insert(true, at: 0)
                case 3:
                    print("閃電箭")
                    // 傳進去下方訊息欄
                    self.messageArray.insert("[閃電箭]造成怪物麻痺,只能使用輕攻擊3回合", at: 0)
                    self.whoTrunArray.insert(true, at: 0)
                    // 麻痹回合數
                    self.paralysisCount += 3
                // 法師系列
                case 4:
                    print("雷擊術")
                    // 一般攻擊，怪物血量減掉角色攻擊力
                    self.bossHp -= (self.actorAtk * self.magicOverload)
                    // 怪物血量文字版
                    self.bossHealthLabel.text = "\(self.bossHp)/\(self.bossStartHp)"
                    // 怪物血量進度條
                    self.bossHealth.progress = Float(self.bossHp) / Float(self.bossStartHp)
                    self.skillAttackChange = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countToWaitAttack), userInfo: nil, repeats: true)
                    // 傳進去下方訊息欄
                    self.messageArray.insert("角色使用了[雷擊術]造成了2段傷害", at: 0)
                    self.whoTrunArray.insert(true, at: 0)
                case 5:
                    print("祕法超載")
                    self.magicOverload = 2
                    // 傳進去下方訊息欄
                    self.messageArray.insert("[祕法超載]讓下回合技能攻擊威力再提升2倍", at: 0)
                    self.whoTrunArray.insert(true, at: 0)
                case 6:
                    print("隕石術")
                    // 一般攻擊，怪物血量減掉角色攻擊力
                    let attack = self.actorAtk * 3 * self.magicOverload
                    self.bossHp -= attack
                    // 如果超載overload不等於1，代表使用完要變回1倍傷害
                    if self.magicOverload > 1 {
                        self.magicOverload = 1
                    }
                    // 怪物血量文字版
                    self.bossHealthLabel.text = "\(self.bossHp)/\(self.bossStartHp)"
                    // 怪物血量進度條
                    self.bossHealth.progress = Float(self.bossHp) / Float(self.bossStartHp)
                    // 傳進去下方訊息欄
                    self.messageArray.insert("角色使用了[隕石術]造成了\(self.actorAtk)*3倍傷害", at: 0)
                    self.whoTrunArray.insert(true, at: 0)
                // 戰士系列
                case 7:
                    print("乞丐大劍")
                    // 一般攻擊，怪物血量減掉角色攻擊力
                    let attack = Float(self.actorAtk) * Float(1.5)
                    self.bossHp -= Int(attack)
                    // 怪物血量文字版
                    self.bossHealthLabel.text = "\(self.bossHp)/\(self.bossStartHp)"
                    // 怪物血量進度條
                    self.bossHealth.progress = Float(self.bossHp) / Float(self.bossStartHp)
                    // 傳進去下方訊息欄
                    self.messageArray.insert("角色使用了[乞丐大劍]造成了\(self.actorAtk)*1.5倍傷害", at: 0)
                    self.whoTrunArray.insert(true, at: 0)
                case 8:
                    print("石化皮膚")
                    self.warriorDefUp += 2
                    // 傳進去下方訊息欄
                    self.messageArray.insert("角色使用了[石化皮膚]提升防禦力30%兩回合", at: 0)
                    self.whoTrunArray.insert(true, at: 0)
                case 9:
                    print("振奮之吼")
                    self.warriorRecovery = true
                    // 回血的計時器
                    myTimerToRecovery = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countRecovery), userInfo: nil, repeats: true)
                default:
                    print("技能失敗")
                }
            }

            // 如果怪物血量歸零，挑戰成功
            guard self.bossHp > 0 else {
                self.actorWinData()
                return
            }

            // 如果今天戰士沒有使用回血技能，則直接進入怪物回合
            if !self.warriorRecovery {
                // 要換怪物的部分
                print("玩家回合結束")
                self.whoTrunImage.image = UIImage(named: "messageMonsterIcon")
                self.whoTurnLabel.text = "怪物的回合"
                self.tableView.reloadData()
                self.characterChange = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countToChangeCharacter), userInfo: nil, repeats: true)
            }
        }
    }
    // MARK: - 補血的計時器功能
    @objc
    private func countRecovery() {
        ActorCount += 50
        if ActorCount >= complete {
            // 重設計數器及 Timer 供下次按下按鈕測試
            ActorCount = 0
            myTimerToRecovery?.invalidate()
            myTimerToRecovery = nil
            // 減少畫面中補品數量
            self.medicineCount -= 1
            self.medicineCountLabel.text = "\(self.medicineCount)"
            // 讓角色回血
            var recovery = 0
            // 如果是戰士使用技能回血的話
            if self.warriorRecovery {
                recovery = Int(Float(self.actorStartHp) * Float(0.2))
            } else {
                recovery = Int(Float(self.actorStartHp) * Float(0.25))
            }
            print("回血INT\(Int(recovery))")
            self.actorHp += Int(recovery)
            // 如果回覆後血量大於原先基礎值，則等於最大值
            if self.actorHp > self.actorStartHp {
                self.actorHp = self.actorStartHp
            }
            // 幫助畫面呈現血量
            self.actorHealthLabel.text = "\(self.actorHp)/\(self.actorStartHp)"
            self.actorHealth.progress = Float(self.actorHp) / Float(self.actorStartHp)
            // 傳進去下方訊息欄
            if self.warriorRecovery {
                self.messageArray.insert("角色使用[振奮之吼]回復了\(Int(recovery))滴血", at: 0)
                self.warriorRecovery.toggle()
            } else {
                self.messageArray.insert("角色使用藥品回復了\(Int(recovery))滴血", at: 0)
            }

            self.whoTrunArray.insert(true, at: 0)
            // 要換怪物的部分
            print("玩家回合結束")
            self.whoTrunImage.image = UIImage(named: "messageMonsterIcon")
            self.whoTurnLabel.text = "怪物的回合"
            self.tableView.reloadData()
            self.characterChange = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countToChangeCharacter), userInfo: nil, repeats: true)
        }
    }
    // MARK: - 換怪物的計時器功能
    @objc
    private func countDown(sender: Timer) {
        MonsterCount += 9
        // 當完成計時
        if MonsterCount >= complete {
            print("怪物回合結束")
            // 重設計數器及 Timer 供下次按下按鈕測試
            MonsterCount = 0
            monsterAttack?.invalidate()
            monsterAttack = nil
            // 如果怪物還活著
            if self.bossHp > 0 {
                // 隨機給怪物這次的攻擊數值ㄌ，如果有麻痺狀態要指定為0
                var attackIndex = 0
                if self.paralysisCount > 0 {
                    attackIndex = 0
                    self.paralysisCount -= 1
                } else {
                    attackIndex = Int.random(in: 0...2)
                }
                // 要扣掉角色本身防禦力，如果有戰士的石化皮膚，則要在加成防禦力
                var attackTemp = 0
                if self.warriorDefUp > 0 {
                    attackTemp = self.bossAttackArray[attackIndex] - Int(Float(self.actorDef) * Float(1.3))
                    self.warriorDefUp -= 1
                } else {
                    attackTemp = self.bossAttackArray[attackIndex] - self.actorDef
                }
                // 如果扣掉角色防禦後，是負數，要變回0
                if attackTemp < 0 {
                    attackTemp = 0
                }
                self.actorHp -= attackTemp
                self.actorHealthLabel.text = "\(self.actorHp)/\(self.actorStartHp)"
                self.actorHealth.progress = Float(self.actorHp) / Float(self.actorStartHp)
                // 傳進去下方訊息欄
                switch attackIndex {
                case 0:
                    self.messageArray.insert("怪物使用輕攻擊，造成\(attackTemp)傷害", at: 0)
                case 1:
                    self.messageArray.insert("怪物使用一般攻擊，造成\(attackTemp)傷害", at: 0)
                case 2:
                    self.messageArray.insert("怪物使用技能攻擊，造成\(attackTemp)傷害", at: 0)
                default:
                    print("攻擊失敗")
                }
                self.whoTrunArray.insert(false, at: 0)
                self.tableView.reloadData()
                self.whoTrunImage.image = UIImage(named: "messageFightIcon")
                self.whoTurnLabel.text = "你的回合"
                self.monsterAttackImage.isHidden = true
                // 計時結束，代表怪物攻擊結束，按鍵效果開啟
                self.actorAttack.isEnabled = true
                self.actorSkill.isEnabled = true
                if self.medicineCount > 0 {
                    self.actorMedicine.isEnabled = true
                }
                // 如果血量低於0，則代表失敗
                if self.actorHp <= 0 {
                    switch self.careerString {
                    case "弓箭手":
                        self.bossImage.image = UIImage(named: "archerDead")
                    case "法師":
                        self.bossImage.image = UIImage(named: "mageDead")
                    case "戰士":
                        self.bossImage.image = UIImage(named: "warriorDead")
                    default:
                        print("error")
                    }
                    self.alertToActorDead()
                }
            }
        }
    }
    // MARK: - 怪物與角色之間切換的計時器功能
    @objc
    private func countToChangeCharacter() {
        characterCount += 50
        // 進度完成時
        if characterCount >= complete {
            // 怪物左右動畫
            self.imageMove()
            self.monsterAttackImage.isHidden = false
            // 重設計數器及 NSTimer 供下次按下按鈕測試
            characterCount = 0
            characterChange?.invalidate()
            characterChange = nil
        }
    }
    // MARK: - 分兩段傷害計時器
    @objc
    private func countToWaitAttack() {
        skillAttack += 50
        // 進度完成時
        if skillAttack >= complete {
            // 一般攻擊，怪物血量減掉角色攻擊力
            self.bossHp -= (self.actorAtk * self.magicOverload)
            // 怪物血量文字版
            self.bossHealthLabel.text = "\(self.bossHp)/\(self.bossStartHp)"
            // 怪物血量進度條
            self.bossHealth.progress = Float(self.bossHp) / Float(self.bossStartHp)
            // 如果超載overload不等於1，代表使用完要變回1倍傷害
            if self.magicOverload > 1 {
                self.magicOverload = 1
            }
            // 重設計數器及 NSTimer 供下次按下按鈕測試
            skillAttack = 0
            skillAttackChange?.invalidate()
            skillAttackChange = nil
        }
    }
    // MARK: - 按下一般攻擊與技能攻擊與補血的基本流程
    private func baseProcess() {
        // 如果是玩家回合，已確認按鍵按下，會先把三個按鍵關掉觸發
        self.actorAttack.isEnabled = false
        self.actorSkill.isEnabled = false
        self.actorMedicine.isEnabled = false
    }
    // MARK: - 角色血量低於0，角色死亡alert
    private func alertToActorDead() {
        let alert = UIAlertController(title: "失敗", message: "角色死亡，請提升等級裝備再來", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: { _ in
            // 失敗後回到主畫面去
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - 角色獲勝alert
    private func alertToActorWin() {
        let alert = UIAlertController(title: "成功", message: "恭喜挑戰成功，獲得\(self.money)塊金錢", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: { _ in
            // 成功後回到主畫面去
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}
// MARK: - 處理SkillView的delegate
extension FightViewController: SkillViewControllerDelegate {
    func receiveSkillInfo(whichSelect: Int) {
        self.unFightBackground.isHidden = true
        // 依職業區分技能效果
        switch self.careerString {
        case "弓箭手":
            // 技能欄(0,1,2)
            switch whichSelect {
            case 0:
                self.skillTemp = 1
                guard consumeMana(consume: Float(0.25)) else {
                    return
                }
            case 1:
                self.skillTemp = 2
                guard consumeMana(consume: Float(0.3)) else {
                    return
                }
            case 2:
                self.skillTemp = 3
                guard consumeMana(consume: Float(0.4)) else {
                    return
                }
            default:
                print("skillError")
            }
        case "法師":
            // 技能欄(0,1,2)
            switch whichSelect {
            // 兩段攻擊
            case 0:
                print("雷擊術")
                self.skillTemp = 4
                guard consumeMana(consume: Float(0.2)) else {
                    return
                }
            case 1:
                print("祕法超載")
                self.skillTemp = 5
                guard consumeMana(consume: Float(0.35)) else {
                    return
                }
            case 2:
                print("隕石術")
                self.skillTemp = 6
                guard consumeMana(consume: Float(0.5)) else {
                    return
                }
            default:
                print("skillError")
            }
        case "戰士":
            // 技能欄(0,1,2)
            switch whichSelect {
            case 0:
                print("乞丐大劍")
                self.skillTemp = 7
                guard consumeMana(consume: Float(0.3)) else {
                    return
                }
            case 1:
                print("石化皮膚")
                self.skillTemp = 8
                guard consumeMana(consume: Float(0.4)) else {
                    return
                }
            case 2:
                print("振奮之吼")
                self.skillTemp = 9
                guard consumeMana(consume: Float(0.5)) else {
                    return
                }
            default:
                print("skillError")
            }
        default:
            print("error")
        }

        // 回合基本流程
        self.baseProcess()
        // 攻擊動畫
        self.attackGifImage.isHidden = false

        // 技能攻擊的計時器，等動畫完成才扣血
        myTimerToNormalAttackAnimated = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countSkillAttack(sender: )), userInfo: nil, repeats: true)

        // 計時開始，換怪物攻擊
        monsterAttack = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countDown(sender: )), userInfo: nil, repeats: true)
    }
    // 魔力不足通知
    private func alertToNotEnoughMana() {
        self.messageArray.insert("魔力不足，使用技能失敗", at: 0)
        self.whoTrunArray.insert(true, at: 0)
        self.tableView.reloadData()
    }
    // 耗魔的func
    private func consumeMana(consume: Float) -> Bool {
        let magicValue = Float(self.actorStartMagic) * consume
        // 如果魔力不足
        guard self.actorMagic > Int(magicValue) else {
            self.alertToNotEnoughMana()
            return false
        }
        self.actorMagic -= Int(magicValue)
        self.actorMagicLabel.text = "\(self.actorMagic)/\(self.actorStartMagic)"
        self.actorMagicProgress.progress = Float(self.actorMagic) / Float(self.actorStartMagic)
        return true
    }
}

// MARK: - 處理Cell的delegate
extension FightViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messageArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FightCell") as? FightTableViewCell else {
            return UITableViewCell()
        }
        cell.fightMessage.text = self.messageArray[indexPath.row]
        if whoTrunArray[indexPath.row] {
            cell.whoImage.image = UIImage(named: "messageFightIcon")
            cell.fightMessage.textColor = UIColor.black
        } else {
            cell.whoImage.image = UIImage(named: "messageMonsterIcon")
            cell.fightMessage.textColor = UIColor.red
        }
        return cell
    }
}
