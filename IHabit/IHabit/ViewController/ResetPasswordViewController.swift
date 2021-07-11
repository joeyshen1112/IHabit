//
//  ResetPasswordViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/7/4.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var enterOldPassword: UITextField!
    @IBOutlet weak var enterNewPassword: UITextField!
    @IBOutlet weak var doubleCheckNewPassword: UITextField!
    @IBOutlet weak var oldPasswordButton: UIButton!
    @IBOutlet weak var newPasswordButton: UIButton!
    @IBOutlet weak var doubleCheckPasswordButton: UIButton!
    @IBOutlet var secureButtonArray: [UIButton]!

    var userDefault = UserDefaults.standard
    var userData: UserInformationData?
    var responseData: ResetPasswordData?
    var email: String?
    // 看見隱藏密碼(舊)
    @IBAction private func oldPasswordButtonAction(_ sender: Any) {
        self.oldPasswordButton.isSelected.toggle()
        if oldPasswordButton.isSelected {
            self.enterOldPassword.isSecureTextEntry = false
        } else {
            self.enterOldPassword.isSecureTextEntry = true
        }
    }
    // 看見隱藏密碼(新)
    @IBAction private func newPasswordButtonAction(_ sender: Any) {
        self.newPasswordButton.isSelected.toggle()
        if newPasswordButton.isSelected {
            self.enterNewPassword.isSecureTextEntry = false
        } else {
            self.enterNewPassword.isSecureTextEntry = true
        }
    }
    // 看見隱藏密碼(檢查)
    @IBAction private func doubleCheckPasswordButtonAction(_ sender: Any) {
        self.doubleCheckPasswordButton.isSelected.toggle()
        if doubleCheckPasswordButton.isSelected {
            self.doubleCheckNewPassword.isSecureTextEntry = false
        } else {
            self.doubleCheckNewPassword.isSecureTextEntry = true
        }
    }
    // 確認的按鈕
    @IBAction private func confirmButtonAction(_ sender: Any) {
        // 按下後確認前後新密碼是否相同，不同則跳出alert
        guard self.enterNewPassword.text == self.doubleCheckNewPassword.text else {
            alertToDoubleCheckPassword()
            return
        }
        // 如果新舊密碼為空，則跳出警告
        if let newPassword = self.enterNewPassword.text,
           let doubleCheckPassword = self.doubleCheckNewPassword.text {
            guard !newPassword.isEmpty, !doubleCheckPassword.isEmpty else {
                alertToDoubleCheckPasswordEmpty()
                return
            }
            self.changePassword()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        enterOldPassword.delegate = self
        enterNewPassword.delegate = self
        doubleCheckNewPassword.delegate = self

        enterOldPassword.isSecureTextEntry = true
        enterNewPassword.isSecureTextEntry = true
        doubleCheckNewPassword.isSecureTextEntry = true

        enterOldPassword.returnKeyType = .done
        enterNewPassword.returnKeyType = .done
        doubleCheckNewPassword.returnKeyType = .done

        secureButtonArray.forEach { button in
            button.setImage(UIImage(systemName: "eye"), for: .normal)
            button.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        secureButtonArray.forEach { button in
            button.isSelected = false
        }
        getUserData()
    }
    // MARK: - 如果新密碼跟再次輸入密碼不相同，則跳出alert
    private func alertToDoubleCheckPassword() {
        let alert = UIAlertController(title: "錯誤", message: "密碼與確認密碼不相同", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default) { _ in
            self.enterNewPassword.text = ""
            self.doubleCheckNewPassword.text = ""
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - 如果新密碼跟再次輸入密碼為空，則跳出alert
    private func alertToDoubleCheckPasswordEmpty() {
        let alert = UIAlertController(title: "錯誤", message: "新密碼不得為空白", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - 傳送重設密碼資料
    private func changePassword() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID,
           let email = self.email,
           let oldPassword = self.enterOldPassword.text,
           let newPassword = self.enterNewPassword.text {
            let parameters = [
                "userId": userID,
                "email": email,
                "originPassword": oldPassword,
                "newPassword": newPassword
            ] as [String: Any]

            print("舊密碼\(oldPassword)")
            print("新密碼\(newPassword)")
            print("檢查密碼\(newPassword)")
            Server.shared.requestPut(path: "/User/ResetPassword", parameters: parameters) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let resetData = try JSONDecoder().decode(ResetPasswordData.self, from: data)
                        self.responseData = resetData
                        if let message = self.responseData?.message {
                            switch message {
                            case "success":
                                print("成功")
                                self.alertToCorrect()
                            case "原密碼錯誤":
                                print("密碼錯誤的alert")
                                self.alertToPasswordWrong()
                            default:
                                print("error")
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
    }
    // MARK: - 舊密碼不對，則跳出alert
    private func alertToPasswordWrong() {
        let alert = UIAlertController(title: "錯誤", message: "舊密碼輸入錯誤", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - 修改成功的alert
    private func alertToCorrect() {
        let alert = UIAlertController(title: "成功", message: "已成功修改密碼", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "確認", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - 拿取使用者資料
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
                        self.userData = userActorInfo
                        if let email = self.userData?.email {
                            self.email = email
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
extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        enterOldPassword.resignFirstResponder()
        enterNewPassword.resignFirstResponder()
        doubleCheckNewPassword.resignFirstResponder()
        return true
    }
    // 讓鍵盤縮下去的功能
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
