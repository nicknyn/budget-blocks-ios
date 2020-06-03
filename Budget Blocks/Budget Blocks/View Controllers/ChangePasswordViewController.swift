//
//  ChangePasswordViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 5/18/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import OktaOidc
import OktaAuthNative

class ChangePasswordViewController: UIViewController {

    private let currentPasswordLabel: UILabel = {
       let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Current Password"
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        return lb
    }()
    
    private let newPasswordLabel: UILabel = {
       let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "New Password"
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        return lb
    }()
    
    private lazy var oldPasswordField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter current password"
        textField.becomeFirstResponder()
        textField.borderStyle = .line
        textField.isSecureTextEntry  = true
        return textField
    }()
    
    private lazy var newPasswordField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder        = "Enter new password"
        textField.borderStyle        = .line
        textField.isSecureTextEntry  = true
        return textField
    }()
    
    private lazy var currentPasswordStackView: UIStackView = {
        let stackView       = UIStackView(arrangedSubviews: [self.currentPasswordLabel,self.oldPasswordField])
        stackView.alignment = .fill
        stackView.axis      = .vertical
        stackView.spacing   = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var newPasswordStackView: UIStackView = {
        let stackView       = UIStackView(arrangedSubviews: [self.newPasswordLabel,self.newPasswordField])
        stackView.alignment = .fill
        stackView.axis      = .vertical
        
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(oldPasswordField)
        view.addSubview(newPasswordField)
        oldPasswordField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        newPasswordField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.addSubview(currentPasswordStackView)
        view.addSubview(newPasswordStackView)
        
        NSLayoutConstraint.activate([
            currentPasswordStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 16),
            currentPasswordStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            currentPasswordStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            
            newPasswordStackView.topAnchor.constraint(equalTo: currentPasswordStackView.bottomAnchor,constant: 20),
            newPasswordStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            newPasswordStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16)
        ])
        
        
        navigationItem.title = "Change Password"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
      
    }
    @objc func saveTapped() {
        print("Change password")
        
        guard let oldPassword = oldPasswordField.text, !oldPassword.isEmpty,
            let newPassword = newPasswordField.text, !newPassword.isEmpty else { return }
        
    }
}
