//
//  FourthOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import LinkKit
import LinkPresentation

class FourthOnboardingViewController: UIViewController {
  
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    //MARK:- Actions
    
    @IBAction func linkAccountTapped(_ sender: UIButton) {
        guard let publicKey       = ProcessInfo.processInfo.environment["PLAID_PUBLIC_KEY"] else { return NSLog("No public key found!") }
        let linkConfiguration     = PLKConfiguration(key: publicKey, env: .sandbox, product: [.auth, .transactions, .identity])
        linkConfiguration.webhook = URL(string: "https://lambda-budget-blocks.herokuapp.com/plaid/webhook")!
        let linkViewController    = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: self)
        present(linkViewController, animated: true)
    }
}

extension FourthOnboardingViewController: PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        print("Hello")
        dismiss(animated: true, completion: nil)
        NetworkingController.shared.sendPlaidPublicTokenToServerToGetAccessToken(publicToken: publicToken, userID: UserController.userID!) { (error) in
            print(error?.localizedDescription)
            // POST the database
        }
        performSegue(withIdentifier: "LinkToDashboard", sender: self)
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        
    }
    
}
