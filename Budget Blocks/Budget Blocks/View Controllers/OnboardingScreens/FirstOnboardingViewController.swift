//
//  FirstOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import OktaOidc
import OktaAuthNative

class FirstOnboardingViewController: UIViewController {

    
    var oktaOidc: OktaOidc?
    var stateManager: OktaOidcStateManager?
    var successStatus: OktaAuthStatus?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is \(successStatus)")
        _ = UserController.shared.createUser(with: [(successStatus?.model.embedded?.user?.profile?.firstName)!,  (successStatus?.model.embedded?.user?.profile?.lastName)!].joined(separator: " "), email: (successStatus?.model.embedded?.user?.profile?.login)!)
        
        guard let oidcClient = self.createOidcClient() else { return }
        oidcClient.authenticate(withSessionToken: (successStatus?.model.sessionToken!)!) {  (stateManager, error) in
           
            print("Access token is \(stateManager?.accessToken!)")
            NetworkingController.shared.registerUserToDatabase(user: UserController.shared.user.userRepresentation!, accessToken: (stateManager!.accessToken!)) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                UserController.userID = user?.data.id
            }
        }
        
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "skip", style: .plain, target: self, action: #selector(skipTapped))
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action:
            #selector(swipeMade(_:)))
        leftRecognizer.direction = .left
        
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action:
            #selector(swipeMade(_:)))
        rightRecognizer.direction = .right
        self.view.addGestureRecognizer(leftRecognizer)
        self.view.addGestureRecognizer(rightRecognizer)
        
       

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
 
    @objc func skipTapped() {
        print("skipping")
    }
    
    @objc func swipeMade(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right  {
            
            dismiss(animated: true, completion: nil)
        }
        if sender.direction == .left {
            performSegue(withIdentifier: "1To2", sender: self)
            
        }
    }
        
    func createOidcClient() -> OktaOidc? {
        var oidcClient: OktaOidc?
        if let config = self.readTestConfig() {
            oidcClient = try? OktaOidc(configuration: config)
        } else {
            oidcClient = try? OktaOidc()
        }
        
        return oidcClient
    }
}
private extension FirstOnboardingViewController {
    func readTestConfig() -> OktaOidcConfig? {
        guard let _ = ProcessInfo.processInfo.environment["OKTA_URL"],
            let testConfig = configForUITests else {
                return nil
                
        }
        return try? OktaOidcConfig(with: testConfig)
    }
    var configForUITests: [String: String]? {
        let env = ProcessInfo.processInfo.environment
        guard let oktaURL = env["OKTA_URL"],
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
