//
//  UILabel+Extension.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/27.
//
import UIKit
import Foundation
// 打字機特效
extension UILabel {
    func setTyping(text: String, characterDelay: TimeInterval = 3.0) {
      self.text = ""

      let writingTask = DispatchWorkItem { [weak self] in
        text.forEach { char in
          DispatchQueue.main.async {
            self?.text?.append(char)
          }
          Thread.sleep(forTimeInterval: characterDelay / 100)
        }
      }

      let queue: DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
      queue.asyncAfter(deadline: .now() + 0.05, execute: writingTask)
    }
}
