//
//  WelcomeViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/24/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import OktaOidc
import OktaAuthNative

class WelcomeViewController: UIViewController {
    
    // MARK:- Outlets-
    
    @IBOutlet private weak var signUpButton: UIButton! {
        didSet {
            signUpButton.isEnabled = false
            signUpButton.isHidden = true
        }
    }
    @IBOutlet private weak var signInButton: UIButton!
    
    var oktaOidc: OktaOidc?
    var stateManager: OktaOidcStateManager?
    
    var networkingController: NetworkingController!
    var delegate: LoginViewControllerDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        navigationController?.navigationBar.isHidden = true
        navigationItem.hidesBackButton = true
        do {
            if let configForUITests = self.configForUITests {
                oktaOidc = try OktaOidc(configuration: OktaOidcConfig(with: configForUITests))
            } else {
                oktaOidc = try OktaOidc()
            }
        } catch let error {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                print(error.localizedDescription)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        if  let oktaOidc = oktaOidc,
            let _ = OktaOidcStateManager.readFromSecureStorage(for: oktaOidc.configuration)?.accessToken {
            self.stateManager = OktaOidcStateManager.readFromSecureStorage(for: oktaOidc.configuration)
                
                self.performSegue(withIdentifier: "ShowDashboard", sender: self)
            
          
        }
        
    }
   
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
    }
    
    
    @IBAction func signInTapped(_ sender: UIButton) {
        oktaOidc?.signInWithBrowser(from: self, callback: { [weak self] stateManager, error in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return
            }
            
            print("Access token is \(stateManager!.accessToken!)")
            print("id token is \(stateManager!.idToken!)")
            print(stateManager?.refreshToken ?? 2)
            self?.stateManager?.clear()
            self?.stateManager = stateManager
            self?.stateManager?.writeToSecureStorage()
            self?.performSegue(withIdentifier: "ShowDashboard", sender: self)
        })
    }
    
    
    
    private func setUpViews() {
        let daybreakBlue = UIColor(red: 0.094, green: 0.565, blue: 1, alpha: 1).cgColor
        
        signUpButton.layer.backgroundColor = daybreakBlue
        signUpButton.layer.cornerRadius = 4
        signUpButton.setTitleColor(.white, for: .normal)
        
        signInButton.layer.cornerRadius = 4
        signInButton.layer.borderWidth = 1
//        signInButton.layer.borderColor = daybreakBlue
        
        if let buttonFontSize = signUpButton.titleLabel?.font.pointSize {
            signUpButton.titleLabel?.font = UIFont(name: "Avenir Next", size: buttonFontSize)
            signInButton.titleLabel?.font = UIFont(name: "Avenir Next", size: buttonFontSize)
        }
    }
    
    // MARK: - Navigation-


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? UITabBarController {
            if let vc = destVC.viewControllers?.first as? UINavigationController {
                if let correctVC = vc.viewControllers.first as? DashboardTableViewController {
                    correctVC.oktaOidc = self.oktaOidc
                    correctVC.stateManager = self.stateManager
                }
            }
        }
    }

}
// UI Tests
private extension WelcomeViewController {
    var configForUITests: [String: String]? {
        let env = ProcessInfo.processInfo.environment
        guard let oktaURL = env["OKTA_URL"], oktaURL.count > 0,
            let clientID = env["CLIENT_ID"],
            let redirectURI = env["REDIRECT_URI"],
            let logoutRedirectURI = env["LOGOUT_REDIRECT_URI"] else {
                return nil
        }
        return ["issuer": "\(oktaURL)/oauth2/default",
            "clientId": clientID,
            "redirectUri": redirectURI,
            "logoutRedirectUri": logoutRedirectURI,
            "scopes": "openid profile offline_access"
        ]
    }
}

