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

    //MARK:- Properties-
    
    private let imageView: UIImageView = {
       let im = UIImageView()
        im.translatesAutoresizingMaskIntoConstraints = false
        im.image = UIImage(named: "BlocksIcon")
        im.contentMode = .scaleAspectFit
        im.layer.cornerRadius = 8
        im.clipsToBounds = true
       
        return im
    }()
    
    private let messageLabel : UILabel = {
       let label = UILabel()
        label.text = "No worries! We will send you an email to reset your password."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Enter account's email"
        textField.borderStyle = .roundedRect
        textField.becomeFirstResponder()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.rightViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .yes
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
    
    
    //MARK:- Life Cycle-
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        setUpUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }

    
    //MARK:- Privates-
    
    private func setUpUI() {
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(stackView)
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: stackView.topAnchor,constant: -32)
        ])
        
       
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.title = "Forgot Password"
    }
  
    private func sendEmailToUser() {
        //
    }

}
extension ForgotPasswordViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Sending Email")
        if  !textField.hasText  {
            showAlert(title: "Please enter your email.", message: "")
        } else {
            showAlert(title: "Email sent!", message: "We just sent you an email with instructions for setting your new password.Please check your inbox. See you soon.")
        }
        textField.resignFirstResponder()
        
        return true
    }
}
