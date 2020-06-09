//
//  SignUpViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var checkmarkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func checkmarkButtonTapped(_ sender: UIButton) {
        
    }
    
    
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        
    }
    
    
    
    @IBAction func goBackToSignInTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
   

}
