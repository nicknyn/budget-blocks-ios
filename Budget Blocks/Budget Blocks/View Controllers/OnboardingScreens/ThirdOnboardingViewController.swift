//
//  ThirdOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit


 enum EditButtonState {
    case edit
    case save
}

class ThirdOnboardingViewController: UIViewController {
 
    var editButtonState = EditButtonState.edit
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.isUserInteractionEnabled = false
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        zipcodeTextField.layer.cornerRadius = 4
        zipcodeTextField.layer.borderWidth = 2
        zipcodeTextField.layer.borderColor = #colorLiteral(red: 0.3165915608, green: 0.7718194127, blue: 0.7388673425, alpha: 1)
        navigationItem.hidesBackButton = true
        
        zipcodeTextField.becomeFirstResponder()
        let arbitraryValue: Int = 5
        if let newPosition = zipcodeTextField.position(from: zipcodeTextField.beginningOfDocument, offset: arbitraryValue) {
            zipcodeTextField.selectedTextRange = zipcodeTextField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    
    @IBAction func editPressed(_ sender: UIButton) {
      
        nameTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        emailTextField.isUserInteractionEnabled = true
        nameTextField.becomeFirstResponder()
      
        switch editButtonState {
            case .edit:
                editButtonState = .save
              sender.setTitle("Save", for: .normal)
            case .save:
                editButtonState = .edit
                sender.setTitle("Edit", for: .normal)
                nameTextField.isUserInteractionEnabled = false
                passwordTextField.isUserInteractionEnabled = false
                emailTextField.isUserInteractionEnabled = false
                nameTextField.resignFirstResponder()
            print("POST to server to change information ...")
        }
        
        
    }
    
  
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func nextTapped(_ sender: UIButton) {
//        guard let publicKey       = ProcessInfo.processInfo.environment["PLAID_PUBLIC_KEY"] else { return NSLog("No public key found!") }
//        let linkConfiguration     = PLKConfiguration(key: publicKey, env: .sandbox, product: [.auth, .transactions, .identity])
//        linkConfiguration.webhook = URL(string: "https://lambda-budget-blocks.herokuapp.com/plaid/webhook")!
//        let linkViewController    = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: self)
//        present(linkViewController, animated: true)
    }
    
    
}
