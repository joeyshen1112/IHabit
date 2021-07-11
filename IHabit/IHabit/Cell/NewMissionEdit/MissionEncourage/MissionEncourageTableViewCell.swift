//
//  MissionEncourageTableViewCell.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/10.
//

import UIKit
protocol MissionEncourageTableViewCellDelegate: AnyObject {
    func receiveSentence(encourage: String)
}

class MissionEncourageTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var presetLabel: UILabel!
    @IBOutlet weak var userWriteTextField: UITextField!
    @IBOutlet weak var randomSentenceButton: UIButton!
    weak var delegate: MissionEncourageTableViewCellDelegate?
    let frequencySentence = FrequencySentence()

    @IBAction private func randomSetenceButtonAction(_ sender: Any) {
        randomSentence()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // 設置鍵盤右下按鍵為done
        userWriteTextField.delegate = self
        userWriteTextField.returnKeyType = .done
        // 隨機的按鈕設置
        randomSentenceButton.layer.cornerRadius = 5
//        randomSentence()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    // 隨機產生一句『鼓勵的話語』
    private func randomSentence() {
        userWriteTextField.placeholder = frequencySentence.getSentence(index: Int.random(in: 0...frequencySentence.getSentenceCount() - 1))
        if let sentence = userWriteTextField.placeholder {
            delegate?.receiveSentence( encourage: sentence)
        }
    }
}
// 處理TextField的Delegate
extension MissionEncourageTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userWriteTextField.resignFirstResponder()
        if let sentence = userWriteTextField.text {
            delegate?.receiveSentence(encourage: sentence)
        }
        return true
    }
}
