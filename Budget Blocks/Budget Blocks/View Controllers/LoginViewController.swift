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
    
    // MARK: Properties
    
    var signIn: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        updateViews()
    }
    
    private func setUpViews() {
        loginButton.setTitle("Sign \(signIn ? "In" : "Up")", for: .normal)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
