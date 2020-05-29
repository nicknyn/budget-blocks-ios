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
    
    // MARK:- Outlets -

    @IBOutlet private weak var loginButton: UIButton!
    
    @IBOutlet private weak var emailTextField: UITextField! {
        didSet {
            emailTextField.clearButtonMode = .whileEditing
            emailTextField.becomeFirstResponder()
        }
    }
    @IBOutlet private weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.clearButtonMode = .whileEditing
        }
    }
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.clearButtonMode = .whileEditing
        }
    }
    @IBOutlet private weak var confirmPasswordLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = imageView.bounds.size.width / 2
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.borderWidth = 2
        }
    }

    // MARK:- Properties-
    
    var networkingController: NetworkingController!
    var userController : UserController!
    var delegate: LoginViewControllerDelegate?
    var loadingGroup = DispatchGroup()
    var signIn: Bool = true
    var firstName: String?
    var lastName: String?
    var namePage: Bool {
        return !signIn && firstName == nil && lastName == nil
    }
    
    private lazy var  forgotPasswordButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.contentHorizontalAlignment = .right
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(#colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(moveToForgotPasswordScreen), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    @objc func moveToForgotPasswordScreen() {
     
      let forgotPasswordViewController = ForgotPasswordViewController()
        self.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    //MARK:- Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        updateViews()
        hideNavigationItemBackground()
        hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
  
    // MARK: Private
  
    private func setUpViews() {
        let title = "Sign \(signIn ? "In" : "Up")"
        loginButton.setTitle(title, for: .normal)

        navigationItem.title = title
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
      
        if signIn {
            view.addSubview(forgotPasswordButton)
            
            NSLayoutConstraint.activate([
                forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
                forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,constant: 8),
                forgotPasswordButton.widthAnchor.constraint(equalToConstant: 200),
                forgotPasswordButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
       
        if let textFieldFontSize = emailTextField.font?.pointSize {
            let exo = UIFont(name: "Avenir Next", size: textFieldFontSize)
            emailTextField.font = exo
            passwordTextField.font = exo
            confirmPasswordTextField.font = exo
        }
        
        if let buttonFontSize = loginButton.titleLabel?.font.pointSize {
            loginButton.titleLabel?.font = UIFont(name: "Avenir Next", size: buttonFontSize)
        }
        
        confirmPasswordTextField.isHidden = signIn || namePage
        confirmPasswordLabel.isHidden = signIn || namePage
        
       
        if namePage {
            
            forgotPasswordButton.isHidden = true
            
            confirmPasswordTextField.isHidden = true
            confirmPasswordLabel.isHidden = true
            
            emailTextField.textContentType = .givenName
            passwordTextField.textContentType = .familyName
            
            emailTextField.autocapitalizationType = .words
            passwordTextField.autocapitalizationType = .words
            
            emailTextField.placeholder = "Enter legal first name"
            passwordTextField.placeholder = "Enter legal last name"
            
            emailLabel.text = "First Name"
            passwordLabel.text = "Last Name"
            
            passwordTextField.isSecureTextEntry = false
            
            loginButton.setTitle("Continue", for: .normal)
        }
    }
    
    private func updateViews() {
    
        //TODO: check the status of the form
        loginButton.layer.cornerRadius = 6
        loginButton.layer.borderWidth = 1
      
    }
    
    private func signUp(email: String, password: String, firstName: String, lastName: String) {
        loadingGroup.enter()
        loading(message: "Signing up...")
        networkingController.register(email: email, password: password, firstName: firstName, lastName: lastName) { message, error in
            DispatchQueue.main.async {
                self.dismissAlert(dispatchGroup: self.loadingGroup)
            }
            
            if let error = error {
                return NSLog("Error signing up: \(error)")
            }
            
            guard let message = message else {
                return NSLog("No message back from register.")
            }
            
            if message == "success" {
                NSLog("Sign up successful!")
                DispatchQueue.main.async {
                    self.signIn(email: email, password: password)
                }
            } else {
                //TODO: alert the user
                print(message)
            }
        }
    }

    // MARK:- Actions-
    
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
        loadingGroup.enter()
        loading(message: "Signing in...")
        networkingController.login(email: email, password: password) { token, error in
            DispatchQueue.main.async {
                self.dismissAlert(dispatchGroup: self.loadingGroup)
            }
            
            if let error = error {
                return NSLog("Error signing in: \(error)")
            }
            
            guard let token = token else {
                return NSLog("No token returned from login.")
            }
            
            print(token)
            self.loadingGroup.notify(queue: .main) {
                self.delegate?.loginSuccessful()
//                self.performSegue(withIdentifier: "Onboard", sender: self)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Navigation-
    
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

// MARK:- Text field delegate-

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
