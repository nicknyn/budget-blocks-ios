//
//  NativeLoginViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/3/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import OktaOidc
import OktaAuthNative
import SVProgressHUD

private enum EyeState {
  case hidePassword
  case unhidePassword
}

private enum CheckmarkState {
  case remember
  case notRemember
}
final class NativeLoginViewController: UIViewController {
  

  @IBOutlet weak var appTitleLabel: UILabel!
  @IBOutlet weak var emailTextField: UITextField! {
    didSet {
      emailTextField.becomeFirstResponder()
    }
  }
  @IBOutlet weak var passwordTextField: UITextField! {
    didSet {
      passwordTextField.rightViewMode = .always
      passwordTextField.isSecureTextEntry = true
    }
  }
  @IBOutlet weak var signInButton: UIButton! { didSet { signInButton.layer.cornerRadius = 4 } }
  @IBOutlet weak var checkmarkButton: UIButton!
  
  var successStatus: OktaAuthStatus?
  fileprivate var checkMarkState: CheckmarkState = .notRemember
  fileprivate var eyeState: EyeState = .hidePassword
  private let eyeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
  private let userDefault = UserDefaults.standard
  //MARK:- Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SVProgressHUD.setDefaultStyle(.dark)
    emailTextField.delegate = self
    passwordTextField.delegate = self
    if userDefault.bool(forKey: "check") == true {
      checkmarkButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
      emailTextField.text = userDefault.string(forKey: "username")
      passwordTextField.text = userDefault.string(forKey: "password")
    } else {
      checkmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
      emailTextField.text = ""
      passwordTextField.text = ""
    }
   
    hideKeyboardWhenTappedAround()
    navigationController?.navigationBar.isHidden = true
    setUpEyeButtonForTextField()
  }
  
  
  private func setUpEyeButtonForTextField() {
    let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: passwordTextField.frame.height))
    
    eyeButton.addTarget(self, action: #selector(eyePreseddd), for: .touchUpInside)
    eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    containerView.addSubview(eyeButton)
    eyeButton.center = containerView.center
    passwordTextField.rightView = containerView
  }
  
  @objc func eyePreseddd() {
    print("HEHEHE")
    switch eyeState {
      case .hidePassword:
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeState = .unhidePassword
        passwordTextField.isSecureTextEntry.toggle()
      default:
        eyeState = .hidePassword
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordTextField.isSecureTextEntry.toggle()
    }
  }
  //MARK:- Actions
  
  @IBAction func checkMarkTapped(_ sender: UIButton) {

    switch checkMarkState {
      case .notRemember:
        checkMarkState = CheckmarkState.remember
        
        userDefault.set(true, forKey: "check")
        userDefault.set(emailTextField.text, forKey: "username")
        userDefault.set(passwordTextField.text, forKey: "password")
        userDefault.synchronize()
        checkmarkButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        
      default:
        checkMarkState = CheckmarkState.notRemember
        userDefault.set(false, forKey: "check")
        
        checkmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
    }
  }
  
  @IBAction func forgotPasswordTapped(_ sender: UIButton) {
    print("Forgot password")
    
  }
  
  @IBAction func signInTapped(_ sender: UIButton) {
    print("Sign in")
    guard let username = emailTextField.text, !username.isEmpty,
      let password = passwordTextField.text,!password.isEmpty else { return }
    
    
    SVProgressHUD.show()
    OktaAuthSdk.authenticate(with: NetworkingController.oktaDomain, username: username, password: password, onStatusChange: { (status) in
      
      DispatchQueue.main.async {
        print(status)
        self.successStatus = status
        SVProgressHUD.dismiss()
        self.performSegue(withIdentifier: "LoginSuccess", sender: self)
      }
    }) { (error) in
      self.showAlert(title: "Wrong username of password", message: error.localizedDescription)
      print(error.localizedDescription)
      print("Wrong password")
      SVProgressHUD.dismiss()
    }
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "LoginSuccess" {
      if let destVC = segue.destination as? UINavigationController {
        if let vc = destVC.viewControllers.first as? FirstOnboardingViewController {
          vc.successStatus = self.successStatus
        }
      }
    }
  }
  
  @IBAction func signUpTapped(_ sender: UIButton) {
    print("Sign up")
    dismiss(animated: true)
  }
}
extension NativeLoginViewController : UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

