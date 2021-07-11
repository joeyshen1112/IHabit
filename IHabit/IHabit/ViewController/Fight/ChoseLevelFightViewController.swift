//
//  ChoseLevelFightViewController.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/7/1.
//

import UIKit

protocol ChoseLevelFightViewControllerDelegate: AnyObject {
    func changeView(level: Int)
}

class ChoseLevelFightViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: ChoseLevelFightViewControllerDelegate?
    var test: Int?
    let monsterName = ["菜雞迅猛龍", "煞氣蝙蝠龍", "火焰龍", "黑甲龍", "獅頭尖牙龍", "翼手黑甲龍", "巨螯古底蟹", "史前烏賊王", "三角恐暴龍", "鋼爪鐵骨龍"]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
extension ChoseLevelFightViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.changeView(level: indexPath.row + 1)
        self.dismiss(animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? LevelFightChoseCollectionViewCell else {
            return UICollectionViewCell()
        }
        // 設定關卡boss圖片
        cell.bossImage.image = UIImage(named: "monster" + "\(indexPath.row + 1)")
        cell.bossName.text = self.monsterName[indexPath.row]
        return cell
    }
}
