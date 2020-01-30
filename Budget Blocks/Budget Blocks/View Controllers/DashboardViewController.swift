//
//  DashboardViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/28/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import LinkKit

class DashboardViewController: UIViewController {
    
    let networkingController = NetworkingController()

    override func viewDidLoad() {
        super.viewDidLoad()

        if networkingController.bearer == nil {
            performSegue(withIdentifier: "InitialLogin", sender: self)
        }
    }
    
    @IBAction func linkAccount(_ sender: Any) {
        guard let publicKey = ProcessInfo.processInfo.environment["PLAID_PUBLIC_KEY"] else {
            return NSLog("No public key found!")
        }
        let linkConfiguration = PLKConfiguration(key: publicKey, env: .sandbox, product: .auth)
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: self)
        present(linkViewController, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        networkingController.logout()
        performSegue(withIdentifier: "AnimatedLogin", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let welcomeVC = segue.destination as? WelcomeViewController {
            welcomeVC.networkingController = networkingController
        } else if let transactionsVC = segue.destination as? TransactionsViewController {
            transactionsVC.networkingController = networkingController
        }
    }

}

// MARK: Plaid Link view delegate

extension DashboardViewController: PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        print("Link successful. Public token: \(publicToken)")
        networkingController.tokenExchange(publicToken: publicToken) { error in
            if let error = error {
                NSLog("Error exchanging token: \(error)")
            }
        }
        dismiss(animated: true)
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        if let error = error {
            NSLog("Error linking bank account: \(error)")
        } else {
            NSLog("Error linking bank account.")
        }
    }
}
