//
//  UIViewController+Loading.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/20/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String,message:String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
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
    
    public func hideNavigationItemBackground() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
}
extension UINavigationController {
    
    func backToViewController(vc: Any) {
        // iterate to find the type of vc
        for element in viewControllers as Array {
            if "\(type(of: element)).Type" == "\(type(of: vc))" {
                self.popToViewController(element, animated: true)
                break
            }
        }
    }
    
}
extension UIViewController {
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }
    func createtextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}
