//
//  RegisteredViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/21.
//

import UIKit

class RegisteredViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var registerMail: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var correctImage: UIImageView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var actorImage: UIImageView!
    @IBOutlet weak var leftChangeActorButton: UIButton!
    @IBOutlet weak var rightChangeActorButton: UIButton!
    @IBOutlet weak var careerName: UILabel!
    @IBOutlet weak var warriorCareerInfor: UILabel!
    @IBOutlet weak var magicCareerInfo: UILabel!
    @IBOutlet weak var archerCareerInfo: UILabel!
    @IBOutlet weak var seePasswordButton: UIButton!
    var userRegisteredData: [UserRegisteredData] = []
    var userCheckMailData: UserCheckMailData?
    var careerID = 3
    // 驗證圖Bool
    var checkMailBool = false
    // 如果email暫存有改變，則要重新驗證
    var userEmailTemp = "" {
        didSet {
            // 如果又偵測到使用者重新輸入，則會變回尚未驗證狀態
            self.correctImage.image = UIImage(named: "warning")
            self.checkMailBool = false
        }
    }
    var actorName = "WALK1"

    @IBAction private func seePasswordButtonAction(_ sender: Any) {
        self.seePasswordButton.isSelected.toggle()
        if seePasswordButton.isSelected {
            self.registerPassword.isSecureTextEntry = false
        } else {
            self.registerPassword.isSecureTextEntry = true
        }
    }
    // 切換角色的按鈕動作，如果職業改變，敘述也要不一樣
    @IBAction private func leftChangeAction(_ sender: Any) {
        switch actorName {
        case "WALK1":
            actorImage.image = UIImage(named: "MageWALK1")
            actorImage.image = UIImage.animatedImageNamed( "MageWALK", duration: 1)
            actorName = "MageWALK1"
            careerInfor(career: actorName)
        case "MageWALK1":
            actorImage.image = UIImage(named: "ArcherWALK1")
            actorImage.image = UIImage.animatedImageNamed("ArcherWALK", duration: 1)
            self.actorName = "ArcherWALK1"
            careerInfor(career: actorName)
        case "ArcherWALK1":
            actorImage.image = UIImage(named: "WALK1")
            actorImage.image = UIImage.animatedImageNamed("WALK", duration: 1)
            self.actorName = "WALK1"
            careerInfor(career: actorName)
        default:
            print("error")
        }
    }
    @IBAction private func rightChangeAction(_ sender: Any) {
        switch actorName {
        case "WALK1":
            actorImage.image = UIImage(named: "ArcherWALK1")
            actorImage.image = UIImage.animatedImageNamed("ArcherWALK", duration: 1)
            self.actorName = "ArcherWALK1"
            careerInfor(career: actorName)
        case "ArcherWALK1":
            actorImage.image = UIImage(named: "MageWALK1")
            actorImage.image = UIImage.animatedImageNamed( "MageWALK", duration: 1)
            self.actorName = "MageWALK1"
            careerInfor(career: actorName)
        case "MageWALK1":
            actorImage.image = UIImage(named: "WALK1")
            actorImage.image = UIImage.animatedImageNamed("WALK", duration: 1)
            self.actorName = "WALK1"
            careerInfor(career: actorName)
        default:
            print("error")
        }
    }

    // 驗證的按鈕動作
    @IBAction private func checkButtonAction(_ sender: Any) {
        guard let mail = registerMail.text,
              !mail.isEmpty,
              validateEmail(email: mail) else {
            self.alertToEmailError(remindText: "此信箱格式錯誤")
            return
        }
        getUserCheckMailData(mail: mail)
    }
    // 驗證信箱格式
    func validateEmail(email: String) -> Bool {
        if email.isEmpty {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    // 確認註冊的按鈕
    @IBAction private func signUpButtonAction(_ sender: Any) {
        // 要先去認是否驗證，以及各個欄位是否為空
        if checkMailBool == true,
           let registerMail = registerMail.text,
           !registerMail.isEmpty,
           let registerPassword = registerPassword.text,
           !registerMail.isEmpty,
           let registerName = registerName.text,
           !registerName.isEmpty {
            postDataByAlamofire(name: registerName, mail: registerMail, password: registerPassword)
        } else {
            self.alertToEmailError(remindText: "尚未驗證信箱，或有欄位尚未填寫")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        registerName.delegate = self
        registerName.returnKeyType = .done
        registerMail.delegate = self
        registerMail.returnKeyType = .done
        registerPassword.delegate = self
        registerPassword.returnKeyType = .done
        signUpButton.layer.cornerRadius = 15
        registerPassword.isSecureTextEntry = true

        seePasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        seePasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        registerMail.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    // MARK: - 隨時偵測鍵盤是否有更新
    @objc func textFieldDidChange(_ textField: UITextField) {
        // 如果有偵測到信箱輸入改變，則會變重新驗證狀態
        if self.userEmailTemp != registerMail.text! {
            self.userEmailTemp = registerMail.text!
        }
        print("已更動")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.seePasswordButton.isSelected = false
        correctImage.image = UIImage(named: "warning")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        checkButton.layer.borderWidth = 1
        checkButton.layer.borderColor = UIColor.white.cgColor
        checkButton.layer.cornerRadius = 5
        magicCareerInfo.isHidden = true
        archerCareerInfo.isHidden = true
        actorImage.image = UIImage(named: "WALK1")
        actorImage.image = UIImage.animatedImageNamed("WALK", duration: 1)
        careerName.text = "戰士："
        warriorCareerInfor.setTyping(text: "剛勇無比的職業，傷害雖然遜於其他兩個職業，但天生血量與防禦素質都非常的高")
    }
    private func postDataByAlamofire(name: String, mail: String, password: String) {
        // 確認使用者選哪個職業
        switch actorName {
        case "WALK1":
            self.careerID = 3
        case "MageWALK1":
            self.careerID = 2
        case "ArcherWALK1":
            self.careerID = 1
        default:
            print("error")
        }

        let postData = [
            "name": name,
            "email": mail,
            "password": password,
            "career": careerID
        ] as [String: Any]

        Server.shared.requestPost(path: "/User/SignUp", parameters: postData) { response in
            switch response {
            case let .success(data):
                // 成功就轉到登入畫面
                print("成功\(data)")
                self.navigationController?.popViewController(animated: true)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    // 驗證信箱
    private func getUserCheckMailData(mail: String) {
        Server.shared.requestGet(path: "/User/isEmailExist/" + mail, parameters: nil) { result in
            switch result {
            case let .success(data):
                do {
                    let userCheckMailData = try JSONDecoder().decode(UserCheckMailData.self, from: data)
                    self.userCheckMailData = userCheckMailData
                    // 如果今天結果是false，代表這個信箱沒有人註冊過
                    if let mailHaveRegistered = self.userCheckMailData?.data {
                        if mailHaveRegistered {
                            self.alertToEmailError(remindText: "此信箱已註冊或格式錯誤")
                            self.correctImage.image = UIImage(named: "warning")
                            self.checkMailBool = false
                        } else {
                            self.correctImage.image = UIImage(named: "correct")
                            self.checkMailBool = true
                        }
                    }
                } catch {
                    print(error)
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    // 註冊有問題的alert
    private func alertToEmailError(remindText: String) {
        let alert = UIAlertController(title: "錯誤", message: remindText, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    // 職業說明
    private func careerInfor(career: String) {
        switch career {
        case "WALK1":
            warriorCareerInfor.isHidden = false
            magicCareerInfo.isHidden = true
            archerCareerInfo.isHidden = true
            careerName.text = "戰士："
            warriorCareerInfor.setTyping(text: "剛勇無比的職業，傷害雖然遜於其他兩個職業，但天生血量與防禦素質都非常的高")
        case "MageWALK1":
            magicCareerInfo.isHidden = false
            warriorCareerInfor.isHidden = true
            archerCareerInfo.isHidden = true
            careerName.text = "法師："
            magicCareerInfo.setTyping(text: "精通元素的奧秘，瞬間傷害的強大蓋過了天生體質上的缺陷，沒有人能小看他的魔法")
        case "ArcherWALK1":
            archerCareerInfo.isHidden = false
            warriorCareerInfor.isHidden = true
            magicCareerInfo.isHidden = true
            careerName.text = "弓箭手："
            archerCareerInfo.setTyping(text: "森林中的狙擊手，百步穿楊的精準射擊，從來沒有人能躲過他的弓箭")
        default:
            print("error")
        }
    }
}
// MARK: - 三個testField的delegate內容
extension RegisteredViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registerName.resignFirstResponder()
        registerMail.resignFirstResponder()
        registerPassword.resignFirstResponder()
        // 如果有偵測到信箱輸入改變，則會變重新驗證狀態
        if self.userEmailTemp != registerMail.text! {
            self.userEmailTemp = registerMail.text!
        }
        return true
    }
    // 點選別的地方可以關掉鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
