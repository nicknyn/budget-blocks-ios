//
//  NativeLoginViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/3/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import SVProgressHUD
import OktaOidc
import OktaAuthNative

private enum EyeState {
    case hidePassword
    case unhidePassword
}

private enum CheckmarkState {
    case remember
    case notRemember
}
 class NativeLoginViewController: UIViewController {
    
 
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.rightViewMode = .always
            passwordTextField.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var signInButton: UIButton! { didSet { signInButton.layer.cornerRadius = 4 } }
    @IBOutlet weak var checkmarkButton: UIButton!
    
    fileprivate var state: CheckmarkState = .notRemember
    fileprivate var eyeState: EyeState = .hidePassword
     let eyeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
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
        
        switch state {
            case .notRemember:
                state = CheckmarkState.remember
                print("Remember")
                checkmarkButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            default:
                state = CheckmarkState.notRemember
                print("Unremember")
                checkmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        print("Forgot password")
        
    }
    
    
    
    @IBAction func signInTapped(_ sender: UIButton) {
        print("Sign in")
    }
    
    
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        print("Sign up")
    }
    
}
