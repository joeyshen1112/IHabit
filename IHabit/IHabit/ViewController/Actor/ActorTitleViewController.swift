//
//  ActorTitleViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/7/5.
//

import UIKit

protocol ActorTitleViewControllerDelegate: AnyObject {
    func receiveTitleName(titleName: String)
}

class ActorTitleViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: ActorTitleViewControllerDelegate?
    var userDefault = UserDefaults.standard
    var titleArray: [String] = []
    var titleNow: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleArray = []
        getUserTitleData()
    }
    // MARK: - 拿取使用者稱號資料
    private func getUserTitleData() {
        let userID = userDefault.value(forKey: "userID") as? Int
        if let userID = userID {
            Server.shared.requestGet(path: "/User/UserTitle/\(userID)", parameters: nil) { response in
                switch response {
                case let .success(data):
                    print(data)
                    do {
                        let titleArray = try JSONDecoder().decode([String].self, from: data)
                        self.titleArray = titleArray
                        // 初出茅蘆一定在最後面
                        self.titleArray.append("初出茅廬")
                        self.tableView.reloadData()
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
extension ActorTitleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") as? TitleTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.titleName.text = self.titleArray[indexPath.row]
        if let titleNow = self.titleNow,
           titleNow == self.titleArray[indexPath.row] {
            cell.isChose.isSelected = true
        }
        return cell
    }
}
extension ActorTitleViewController: TitleTableViewCellDelegate {
    func receiveTitleName(title: String) {
        self.delegate?.receiveTitleName(titleName: title)
        self.putUserData(titleName: title)
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - 修改會員資料的post
    private func putUserData(titleName: String) {
        let userID = userDefault.value(forKey: "userID") as? Int
        let email = userDefault.value(forKey: "email") as? String
        if let userID = userID,
           let email = email {
            let parameters = [
                "userId": userID,
                "email": email,
                "title": titleName
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
}
