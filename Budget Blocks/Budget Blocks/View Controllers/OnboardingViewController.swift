//
//  OnboardingViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/19/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import LinkKit
import CoreData

protocol OnboardingViewControllerDelegate: AnyObject {
    func accountConnected()
}

class OnboardingViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var plaidView: UIView! {
        didSet {
            plaidView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
            plaidView.layer.cornerRadius = 56
        }
    }
    @IBOutlet private weak var manualView: UIView! {
        didSet {
            manualView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
            manualView.layer.cornerRadius = 56
        }
    }
    
    // MARK: Properties
    
    var transactionController: TransactionController!
    var networkingController: NetworkingController!
    weak var delegate: OnboardingViewControllerDelegate?
    let loadingGroup = DispatchGroup()
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let plaidTap = UITapGestureRecognizer(target: self, action: #selector(plaid))
        plaidView.addGestureRecognizer(plaidTap)
        
       
        let manualTap = UITapGestureRecognizer(target: self, action: #selector(manual))
        manualView.addGestureRecognizer(manualTap)
        
        // Check if the user already selected manual but just never set any categories
        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
        if let allCategories = try? CoreDataStack.shared.mainContext.fetch(fetchRequest),
            !allCategories.isEmpty {
            // If there are categories already
            self.performSegue(withIdentifier: "InitialBudgetNoAnimation", sender: self)
        }
    }
    
    // MARK: Private
    
    private func fetchCategoriesAndSegue() {
        loadingGroup.enter()
        loading(message: "Fetching categories...", dispatchGroup: loadingGroup)
        transactionController.updateCategoriesFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            self.loadingGroup.notify(queue: .main, execute: {
                self.delegate?.accountConnected()
                self.loadingGroup.enter()
                self.dismissAlert(dispatchGroup: self.loadingGroup)
            })
            
            if let error = error {
                return NSLog("\(error)")
            }
            
            self.loadingGroup.notify(queue: .main, execute: {
                self.performSegue(withIdentifier: "InitialBudget", sender: self)
            })
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
        linkViewController.modalPresentationStyle = .fullScreen
        present(linkViewController, animated: true)
    }
    
    @objc private func manual() {
        print("Manual")
        loadingGroup.enter()
        loading(message: "Connecting account...", dispatchGroup: loadingGroup)
        
        networkingController.manualOnboard { error in
            self.loadingGroup.notify(queue: .main, execute: {
                self.loadingGroup.enter()
                self.dismissAlert(dispatchGroup: self.loadingGroup)
            })
            
            self.loadingGroup.notify(queue: .main, execute: {
                self.fetchCategoriesAndSegue()
            })
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let blocksVC = segue.destination as? BlocksViewController {
            blocksVC.transactionController = transactionController
            blocksVC.isModalInPresentation = true
            blocksVC.navigationItem.rightBarButtonItem = nil
        }
    }

}

// MARK: Plaid Link view delegate

extension OnboardingViewController: PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true)
        print("Link successful. Public token: \(publicToken)")
        loadingGroup.enter()
        loading(message: "Connecting account to Budget Blocks...", dispatchGroup: loadingGroup)
        
        networkingController.tokenExchange(publicToken: publicToken) { error in
            self.loadingGroup.notify(queue: .main, execute: {
                self.loadingGroup.enter()
                self.dismissAlert(dispatchGroup: self.loadingGroup)
            })
            
            if let error = error {
                return NSLog("Error exchanging token: \(error)")
            }
            
            self.networkingController.setLinked()
            self.loadingGroup.notify(queue: .main, execute: {
                self.fetchCategoriesAndSegue()
            })
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
