//
//  ForgotPasswordViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 5/13/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController
{

    private let messageLabel : UILabel = {
       let label = UILabel()
        label.text = "No worries! We will send you an email to reset your password."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir Next", size: 16)
        
        label.numberOfLines = 0
        return label
    }()
    
    private let emailTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.becomeFirstResponder()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.messageLabel,self.emailTextField])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        view.addSubview(stackView)
        view.backgroundColor = .secondarySystemBackground
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16)
        ])
        
        
        navigationItem.title = "Forgot Password"
      
        
        
       
    }
    

   
}
