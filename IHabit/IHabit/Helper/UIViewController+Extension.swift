//
//  UIViewController+Extension.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/16.
//

import UIKit

extension UIViewController {
    func addChild(childController: UIViewController, to view: UIView) {
        self.addChild(childController)
        childController.view.frame = view.bounds
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    func alertMessage(title: String?, message: String?, actionTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
