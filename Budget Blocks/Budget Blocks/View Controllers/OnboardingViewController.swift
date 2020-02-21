//
//  OnboardingViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/19/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import LinkKit

class OnboardingViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var plaidView: UIView!
    @IBOutlet weak var manualView: UIView!
    
    // MARK: Properties
    
    var transactionController: TransactionController!
    var networkingController: NetworkingController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        plaidView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        plaidView.layer.cornerRadius = 56
        let plaidTap = UITapGestureRecognizer(target: self, action: #selector(plaid))
        plaidView.addGestureRecognizer(plaidTap)
        
        manualView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        manualView.layer.cornerRadius = 56
        let manualTap = UITapGestureRecognizer(target: self, action: #selector(manual))
        manualView.addGestureRecognizer(manualTap)
    }
    
    // MARK: Private
    
    private func fetchCategoriesAndSegue() {
        transactionController.updateCategoriesFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            
            if let error = error {
                return NSLog("\(error)")
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "InitialBudget", sender: self)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func plaid() {
        print("Plaid")
        guard let publicKey = ProcessInfo.processInfo.environment["PLAID_PUBLIC_KEY"] else {
            return NSLog("No public key found!")
        }
        let linkConfiguration = PLKConfiguration(key: publicKey, env: .sandbox, product: [.auth, .transactions, .identity])
        linkConfiguration.webhook = URL(string: "https://lambda-budget-blocks.herokuapp.com/plaid/webhook")!
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: self)
        present(linkViewController, animated: true)
    }
    
    @objc private func manual() {
        print("Manual")
        fetchCategoriesAndSegue()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let blocksVC = segue.destination as? BlocksViewController {
            blocksVC.transactionController = transactionController
        }
    }

}

// MARK: Plaid Link view delegate

extension OnboardingViewController: PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true)
        print("Link successful. Public token: \(publicToken)")
        loading(message: "Connecting account to Budget Blocks...")
        networkingController.tokenExchange(publicToken: publicToken) { error in
            DispatchQueue.main.async {
                self.dismissAlert()
            }
            
            if let error = error {
                return NSLog("Error exchanging token: \(error)")
            }
            
            self.networkingController.setLinked()
            DispatchQueue.main.async {
                self.fetchCategoriesAndSegue()
            }
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true)
        if let error = error {
            NSLog("Error linking bank account: \(error)")
        } else {
            NSLog("Error linking bank account.")
        }
    }
}
