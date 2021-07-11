//
//  SettingViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/8.
//

import UIKit
import CoreData

class SettingViewController: UIViewController {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userCareer: UIImageView!

    var userDefault = UserDefaults.standard
    var userData: UserInformationData?
    var actorName = ""

    // 登出
    @IBAction private func turnBackAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    // 重設角色暱稱
    @IBAction private func resetActorName(_ sender: Any) {
        self.alertToChaneName()
    }
    // 重設密碼
    @IBAction private func resignPassword(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserData()
    }
    // MARK: - 修改暱稱的alert
    private func alertToChaneName() {
        let alert = UIAlertController(title: "修改", message: "請輸入新的暱稱", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) -> Void in
            textField.placeholder = "\(self.actorName)"
            textField.returnKeyType = .done
        }
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        let okButton = UIAlertAction(title: "確認", style: .default) { _ in
            let name = alert.textFields?.first?.text
            if let name = name {
                print("新名字為\(name)")
                self.userName.text = "角色暱稱：\(name)"
                self.putUserData(newName: name)
            }
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - 發送修改使用者暱稱api
    private func putUserData(newName: String) {
        let userID = userDefault.value(forKey: "userID") as? Int
        let email = userDefault.value(forKey: "email") as? String
        if let userID = userID,
           let email = email {
            let parameters = [
                "userId": userID,
                "email": email,
                "name": newName
            ] as [String: Any]
            Server.shared.requestPut(path: "/User/UpdateUser", parameters: parameters) { response in
                switch response {
                case let .success(data):
                print(data)
                case let .failure(error):
                print(error.localizedDescription)
                }
            }
        }
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
                        if let name = self.userData?.name,
                           let email = self.userData?.email,
                           let icon = self.userData?.career {
                            self.userName.text = "角色暱稱：\(name)"
                            self.userEmail.text = "信箱：\(email)"
                            self.actorName = name
                            // 職業圖片
                            switch icon {
                            case "弓箭手":
                                self.userCareer.image = UIImage(named: "Mirror_RangerHead_Image")
                            case "法師":
                                self.userCareer.image = UIImage(named: "HEALER_HEAD")
                            case "戰士":
                                self.userCareer.image = UIImage(named: "BERZERKER_HEAD")
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
}
