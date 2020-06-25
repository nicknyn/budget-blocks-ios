//
//  NativeSignUpViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import OktaAuthNative
import OktaOidc
import SVProgressHUD

final class NativeSignUpViewController: UIViewController {
  
  //MARK:- Outlets
  
  @IBOutlet weak var firstNameTextField: UITextField! { didSet { firstNameTextField.becomeFirstResponder() } }
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField! { didSet { passwordTextField.isSecureTextEntry = true } }
  @IBOutlet weak var checkmarkButton: UIButton!
  
  private var isChecked = false
  private var successStatus: OktaAuthStatus?
 
  //MARK:- Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    setUpTextFieldDelegate()
    SVProgressHUD.setDefaultStyle(.dark)
  }
  
  //MARK:- Actions
  
  private func setUpTextFieldDelegate() {
    firstNameTextField.delegate = self
    lastNameTextField.delegate = self
    emailTextField.delegate = self
    passwordTextField.delegate = self
  }
  
  @IBAction func checkmarkButtonTapped(_ sender: UIButton) {
    isChecked.toggle()
    checkmarkButton.setImage(isChecked ?
      UIImage(systemName: "checkmark.square") : UIImage(systemName:"square"), for: .normal)
    print("Remember me")
    
  }
  
  @IBAction func createAccountTapped(_ sender: UIButton) {
    print("Creating account...")
    
    guard let firstName = self.firstNameTextField.text,
      let lastName = self.lastNameTextField.text,
      let username = self.emailTextField.text,
      let password = self.passwordTextField.text,
      firstNameTextField.hasText,
      lastNameTextField.hasText,
      emailTextField.hasText,
      passwordTextField.hasText else { return }
    
    let newUser = RegisteringUser(profile: Profile(firstName: firstName,
                                                   lastName: lastName,
                                                   email: username, // email and login are the same
                                                   login: username,
                                                   mobilePhone: nil),
                                  credentials: Credentials(password: Password(value: password)))
    
    NetworkingController.shared.registerNewUser(user: newUser) { (result) in
      switch result {
        case .failure(let error):
          DispatchQueue.main.async {
            print(error.localizedDescription)
            self.showAlert(title: "Error signing up ", message: error.localizedDescription)
        }
        case.success( _):
          DispatchQueue.main.async {
            SVProgressHUD.show()
          }
          
          OktaAuthSdk.authenticate(with: NetworkingController.oktaDomain, username: username, password: password, onStatusChange: { (status) in
            DispatchQueue.main.async {
              print(status)
              self.successStatus = status
              SVProgressHUD.dismiss()
              self.performSegue(withIdentifier: "SignUpToDashBoard", sender: self)
            }
          }) { (error) in
            self.showAlert(title: "Wrong username of password", message: error.localizedDescription)
            print(error.localizedDescription)
            print("Wrong password")
            SVProgressHUD.dismiss()
        }
      }
    }
  }
  
  @IBAction func goBackToSignInTapped(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "SignUpToDashBoard" {
      if let destVC = segue.destination as? UINavigationController {
        if let vc = destVC.viewControllers.first as? FirstOnboardingViewController {
          vc.successStatus = self.successStatus
        }
      }
    }
  }
}
extension NativeSignUpViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
