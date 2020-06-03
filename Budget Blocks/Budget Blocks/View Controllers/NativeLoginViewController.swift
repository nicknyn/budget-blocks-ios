//
//  NativeLoginViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/3/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

 class NativeLoginViewController: UIViewController {
    
 
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.rightViewMode = .always
        }
    }
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.layer.cornerRadius = 4
        }
    }

    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: passwordTextField.frame.height))
        let eyeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        eyeButton.addTarget(self, action: #selector(eyePreseddd), for: .touchUpInside)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        containerView.addSubview(eyeButton)
        eyeButton.center = containerView.center
        passwordTextField.rightView = containerView
        
        navigationController?.navigationBar.isHidden = true
    }
    

    @objc func eyePreseddd() {
        print("HEHEHE")
    }
    
    //MARK:- Actions
    
    
    
    @IBAction func checkMarkTapped(_ sender: UIButton) {
        print("Uncheck")
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
