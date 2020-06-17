//
//  SignUpViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import OktaAuthNative
import OktaOidc
import SVProgressHUD

class SignUpViewController: UIViewController {

    //MARK:- Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkmarkButton: UIButton!
    
    var isChecked = false
    
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
    }
    
    @IBAction func checkmarkButtonTapped(_ sender: UIButton) {
        isChecked.toggle()
        checkmarkButton.setImage(isChecked ?
            UIImage(systemName: "checkmark.square") : UIImage(systemName:"square"), for: .normal)
        print("Remember me")
        
    }
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        print("Creating account...")
        
    }
    
    @IBAction func goBackToSignInTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
