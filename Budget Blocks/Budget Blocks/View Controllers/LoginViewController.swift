//
//  LoginViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/27/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    // MARK: Properties
    
    var networkingController = NetworkingController()
    var signIn: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        updateViews()
    }
    
    private func setUpViews() {
        let title = "Sign \(signIn ? "In" : "Up")"
        loginButton.setTitle(title, for: .normal)
        loginLabel.text = title
        
        confirmPasswordTextField.isHidden = signIn
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    private func updateViews() {
        let daybreakBlue = UIColor(red: 0.094, green: 0.565, blue: 1, alpha: 1)
        
        //TODO: check the status of the form
        if false {
            
        } else {
            loginButton.layer.cornerRadius = 4
            loginButton.layer.borderWidth = 1
            loginButton.layer.borderColor = daybreakBlue.cgColor
            loginButton.setTitleColor(daybreakBlue, for: .normal)
        }
    }
    
    // MARK: Actions
    
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty else { return }
        
        if signIn {
            networkingController.login(email: email, password: password) { token, error in
                if let error = error {
                    return NSLog("Error signing in: \(error)")
                }
                
                guard let token = token else {
                    return NSLog("No token returned from login.")
                }
                
                print(token)
            }
        } else {
            guard let confirmPassword = confirmPasswordTextField.text,
                confirmPassword == password else {
                    //TODO: indicate this to the user
                    print("Passwords don't match!")
                    return
            }
            
            networkingController.register(email: email, password: password) { message, error in
                if let error = error {
                    return NSLog("Error signing up: \(error)")
                }
                
                guard let message = message else {
                    return NSLog("No message back from register.")
                }
                
                if message == email {
                    NSLog("Sign in successful with email: \(message)")
                } else {
                    //TODO: alert the user
                    print(message)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField where !signIn:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
}
