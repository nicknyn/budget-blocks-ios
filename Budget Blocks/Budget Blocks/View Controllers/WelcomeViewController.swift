//
//  WelcomeViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/24/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var networkingController: NetworkingController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }

    private func setUpViews() {
        let daybreakBlue = UIColor(red: 0.094, green: 0.565, blue: 1, alpha: 1).cgColor
        
        signUpButton.layer.backgroundColor = daybreakBlue
        signUpButton.layer.cornerRadius = 4
        signUpButton.setTitleColor(.white, for: .normal)
        
        signInButton.layer.cornerRadius = 4
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = daybreakBlue
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginVC = segue.destination as? LoginViewController {
            loginVC.delegate = self
            loginVC.signIn = segue.identifier == "SignIn"
            loginVC.networkingController = networkingController
        }
    }

}

// MARK: Login view controller delegate

extension WelcomeViewController: LoginViewControllerDelegate {
    func loginSuccessful() {
        dismiss(animated: true)
        dismiss(animated: true)
    }
}

