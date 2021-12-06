//
//  SignInViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/21.
//

import UIKit

class SignInViewController: UIViewController {
    
    /// email欄位
    @IBOutlet weak var emailTextField: UITextField!
    
    /// 密碼欄位
    @IBOutlet weak var passwordTextField: UITextField!
    
    /// 登入欄位
    @IBOutlet weak var loginButton: UIButton!
    
    /// 註冊欄位
    @IBOutlet weak var signUpButton: UIButton!
    
    /// 檢視密碼欄位
    @IBOutlet weak var seePasswordButton: UIButton!
    
    /// 忘記密碼按鈕
    @IBOutlet weak var forgetPassword: UIButton!
    
    private lazy var viewModel: SignInViewModel = {
        let viewModel = SignInViewModel()
        return viewModel
    }()
    
    private let story = UIStoryboard(name: "Main", bundle: nil)
    
    private let userDefault = UserDefaults.standard
    
    private var missions: [HabitListData] = []
    
    private var forGetPasswordEmail: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.seePasswordButton.isSelected = false
    }
    
    // MARK: - private method
    
    private func setupUI() {
        loginButton.layer.cornerRadius = 15
        signUpButton.layer.cornerRadius = 15
        emailTextField.delegate = self
        emailTextField.returnKeyType = .done
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .done
        self.passwordTextField.isSecureTextEntry = true
        
        seePasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        seePasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
    }
    
    // 忘記密碼的alert
    private func alertToCheckEmailToGetPassword() {
        let alert = UIAlertController(title: "請輸入註冊的信箱", message: "我們將會寄另一組密碼給您", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) -> Void in
            textField.placeholder = "註冊信箱"
            textField.returnKeyType = .done
        }
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        
        let okButton = UIAlertAction(title: "確認", style: .default) { _ in
            if let forGetPasswordEmail = alert.textFields?.first?.text {
                // get Api
                print("帳號\(forGetPasswordEmail)")
                Server.shared.requestGet(path: "/User/ForgetPassWord/\(forGetPasswordEmail)", parameters: nil) { response in
                    switch response {
                    case let .success(data):
                        print(data)
                    case let .failure(error):
                        print(error)
                    }
                }
            }
            // 已寄出新密碼的alert
            self.alertToSendEmail()
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    // 發出驗證信的alert
    private func alertToSendEmail() {
        let alert = UIAlertController(title: "已寄出新密碼至註冊信箱", message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func alertToLoginUpError() {
        let alert = UIAlertController(title: "錯誤", message: "信箱帳號或密碼錯誤", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    // MARK: - 取得資料庫資料
    private func getData(userID: Int) {
        // 這兩個要歸零，不然會重複
        self.missions = []
        Server.shared.requestGet(path: "/GetHabitList/" + "\(userID)", parameters: nil) { result in
            switch result {
            case let .success(data):
                do {
                    let missions = try JSONDecoder().decode([HabitListData].self, from: data)
                    self.missions = missions
                    self.missions.forEach { item in
                        if let habitName = item.habitName,
                           let isInform = item.isInform, isInform == true {
                            // 把時間拆分成hour與minute
                            let timeArray = item.informTime?.split(separator: ":")
                            if let timeArray = timeArray,
                               let hour = Int(timeArray[0]),
                               let minute = Int(timeArray[1]) {
                                print("任務名：\(habitName)、小時\(hour)、分鐘\(minute)")
                                self.setRemindTime(missionName: habitName, hour: hour, minute: minute)
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
    }
    
    // 推播通知建立
    private func setRemindTime(missionName: String, hour: Int, minute: Int) {
        // 將時間放入提醒的推播通知系統中
        let content = UNMutableNotificationContent()
        content.title = "今天執行\(missionName)了嗎？"
        content.body = "趕快回來執行習慣唷"
        content.sound = UNNotificationSound.default
        
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: missionName, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // MARK: - @IBAction
    
    // 忘記密碼
    @IBAction private func forgetButtonAction(_ sender: Any) {
        self.alertToCheckEmailToGetPassword()
    }
    
    // 看見隱藏密碼
    @IBAction private func seePasswordButtonAction(_ sender: UIButton) {
        self.seePasswordButton.isSelected.toggle()
        if seePasswordButton.isSelected {
            self.passwordTextField.isSecureTextEntry = false
        } else {
            self.passwordTextField.isSecureTextEntry = true
        }
    }
    
    // 按下登入的按鍵action
    @IBAction private func loginButtonAction(_ sender: Any) {
        // 刪除通知全部紀錄
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let tabBarVC = story.instantiateViewController(identifier: "TabBarViewController") as? TabBarViewController
        guard let tabBarViewController = tabBarVC,
              let email = emailTextField.text ,
              let password = passwordTextField.text else {
                  alertToLoginUpError()
                  return
              }
        let loginData = [
            "email": email,
            "password": password
        ]
        Server.shared.requestPost(path: "/User/LogIn", parameters: loginData) { response in
            switch response {
            case let .success(data):
                do {
                    let currentData = try JSONDecoder().decode(UserLoginData.self, from: data)
                    if let message = currentData.message,
                       let userID = currentData.data,
                       message == "登入成功" {
                        // 設定登入ID
                        self.userDefault.setValue(userID, forKey: "userID")
                        // 設定登入信箱
                        self.userDefault.setValue(email, forKey: "email")
                        // 拿使用者的習慣清單，並且設定通知
                        self.getData(userID: userID)
                        self.navigationController?.pushViewController(tabBarViewController, animated: true)
                    } else {
                        // 登入失敗就跳出訊息警告
                        self.alertToLoginUpError()
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

// MARK: - 兩個testField的delegate內容
extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    // 點選別的地方可以關掉鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
