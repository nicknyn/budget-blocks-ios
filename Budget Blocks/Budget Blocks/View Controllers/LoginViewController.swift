//
//  LoginViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/27/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func loginSuccessful()
}

class LoginViewController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    // MARK: Properties
    
    var networkingController: NetworkingController!
    var delegate: LoginViewControllerDelegate?
    var signIn: Bool = true
    var firstName: String?
    var lastName: String?
    var namePage: Bool {
        return !signIn && firstName == nil && lastName == nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        updateViews()
    }
    
    // MARK: Private
    
    private func setUpViews() {
        let title = "Sign \(signIn ? "In" : "Up")"
        loginButton.setTitle(title, for: .normal)
        loginLabel.text = title
        
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        let loginLabelFontSize = loginLabel.font.pointSize
        loginLabel.font = UIFont(name: "Exo-Regular", size: loginLabelFontSize)
        
        if let textFieldFontSize = emailTextField.font?.pointSize {
            let exo = UIFont(name: "Exo-Regular", size: textFieldFontSize)
            emailTextField.font = exo
            passwordTextField.font = exo
            confirmPasswordTextField.font = exo
        }
        
        if let buttonFontSize = loginButton.titleLabel?.font.pointSize {
            loginButton.titleLabel?.font = UIFont(name: "Exo-Regular", size: buttonFontSize)
        }
        
        confirmPasswordTextField.isHidden = signIn || namePage
        confirmPasswordLabel.isHidden = signIn || namePage
        
        if namePage {
            confirmPasswordTextField.isHidden = true
            confirmPasswordLabel.isHidden = true
            
            emailTextField.textContentType = .givenName
            passwordTextField.textContentType = .familyName
            
            emailTextField.autocapitalizationType = .words
            passwordTextField.autocapitalizationType = .words
            
            emailTextField.placeholder = "First Name"
            passwordTextField.placeholder = "Last Name"
            
            emailLabel.text = "First Name"
            passwordLabel.text = "Last Name"
            
            passwordTextField.isSecureTextEntry = false
            
            loginButton.setTitle("Continue", for: .normal)
        }
    }
    
    private func updateViews() {
        let daybreakBlue = UIColor(red: 0.094, green: 0.565, blue: 1, alpha: 1)
        
        //TODO: check the status of the form
        loginButton.layer.cornerRadius = 4
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = daybreakBlue.cgColor
        loginButton.setTitleColor(daybreakBlue, for: .normal)
    }
    
    private func signUp(email: String, password: String, firstName: String, lastName: String) {
        networkingController.register(email: email, password: password) { message, error in
            if let error = error {
                return NSLog("Error signing up: \(error)")
            }
            
            guard let message = message else {
                return NSLog("No message back from register.")
            }
            
            if message == "success" {
                NSLog("Sign up successful!")
                self.signIn(email: email, password: password)
            } else {
                //TODO: alert the user
                print(message)
            }
        }
    }

    // MARK: Actions
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty else { return }
        
        if signIn {
            signIn(email: email, password: password)
        } else {
            if let firstName = firstName,
                let lastName = lastName {
                
                guard let confirmPassword = confirmPasswordTextField.text,
                    confirmPassword == password else {
                        //TODO: indicate this to the user
                        print("Passwords don't match!")
                        return
                }
                
                signUp(email: email, password: password, firstName: firstName, lastName: lastName)
            }
        }
    }
    
    private func signIn(email: String, password: String) {
        networkingController.login(email: email, password: password) { token, error in
            if let error = error {
                return NSLog("Error signing in: \(error)")
            }
            
            guard let token = token else {
                return NSLog("No token returned from login.")
            }
            
            print(token)
            DispatchQueue.main.async {
                self.delegate?.loginSuccessful()
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Nacigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "SignUpNext":
            return namePage && !(emailTextField.text?.isEmpty ?? true) && !(passwordTextField.text?.isEmpty ?? true)
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginVC = segue.destination as? LoginViewController {
            loginVC.networkingController = networkingController
            loginVC.delegate = delegate
            loginVC.signIn = false
            loginVC.firstName = emailTextField.text
            loginVC.lastName = passwordTextField.text
        }
    }

}

// MARK: Text field delegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField where !signIn && !namePage:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
}
