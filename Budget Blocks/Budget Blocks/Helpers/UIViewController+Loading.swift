//
//  UIViewController+Loading.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/20/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

extension UIViewController {
    func loading(message: String, dispatchGroup: DispatchGroup? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true) {
            dispatchGroup?.leave()
        }
    }
    
    func dismissAlert(dispatchGroup: DispatchGroup? = nil) {
        if let vc = self.presentedViewController,
            vc is UIAlertController {
            dismiss(animated: true) {
                dispatchGroup?.leave()
            }
        }
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
