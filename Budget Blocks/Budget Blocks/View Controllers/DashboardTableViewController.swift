//
//  DashboardTableViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/3/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import LinkKit
import CoreData

class DashboardTableViewController: UITableViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    
    // MARK: Properties
    
    let networkingController = NetworkingController()
    let transactionController = TransactionController()
    
    lazy var transactionsFRC: NSFetchedResultsController<Transaction> = {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let context = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error fetching transactions: \(error)")
        }
        
        return frc
    }()
    
    lazy var categoriesFRC: NSFetchedResultsController<TransactionCategory> = {
        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        let predicate = NSPredicate(format: "transactions.@count > 0 AND budget > 0")
        fetchRequest.predicate = predicate
        
        let context = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error fetching transactions: \(error)")
        }
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBalances()
        
        transactionController.networkingController = networkingController
        transactionController.updateCategoriesFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            if let error = error {
                return NSLog("\(error)")
            }
        }
        transactionController.updateTransactionsFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            DispatchQueue.main.async {
                // This might be able to be removed since the FRC controllerDidChange function updates balances
                self.updateBalances()
            }
            
            if let error = error {
                return NSLog("\(error)")
            }
        }
        
        let largeTitleFontSize = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.largeTitle).pointSize
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Exo-Regular", size: largeTitleFontSize)!]

        if networkingController.bearer == nil {
            performSegue(withIdentifier: "InitialLogin", sender: self)
        }
        
        // Temporary logout button until the profile page is set up
        let logoutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem = logoutButton
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return networkingController.linkedAccount ? 2 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch adjustedSection(index: section) {
        case 2:
            return categoriesFRC.fetchedObjects?.count ?? 0
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let adjustedSection = self.adjustedSection(index: indexPath.section)
        
        switch adjustedSection {
        case 0...1:
            let uiCell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath)
            guard let cell = uiCell as? DashboardTableViewCell else { return uiCell }
            
            let cellText: String
            var cellImage: UIImage?
            if adjustedSection == 0 {
                cellText = "Connect your bank with Plaid"
                cellImage = UIImage(named: "plaid-logo-icon")
            } else {
                cellText = "View All Transactions"
                cellImage = UIImage(named: "budget")
            }
            cell.titleLabel.text = cellText
            cell.rightImageView.image = cellImage
            
            return cell
        default:
            let uiCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            guard let cell = uiCell as? CategoryTableViewCell else { return uiCell }
            
            let textSize = cell.titleLabel.font.pointSize
            cell.titleLabel.font = UIFont(name: "Exo-Regular", size: textSize)
            cell.detailLabel.font = UIFont(name: "Exo-Regular", size: 12.0)
            
            if let category = categoriesFRC.fetchedObjects?[indexPath.row] {
                cell.titleLabel.text = category.name
                var sum: Int64 = 0
                for transaction in category.transactions ?? [] {
                    guard let transaction = transaction as? Transaction else { continue }
                    sum += transaction.amount
                }
                cell.detailLabel.text = "$\(sum.currency) / $\(category.budget.currency)"
                
                let progress = Float(sum) / Float(category.budget)
                cell.progressBar.progress = progress
                if progress < 0.8 {
                    cell.progressBar.progressTintColor = UIColor(red:0.32, green:0.77, blue:0.10, alpha:1.0)
                } else {
                    cell.progressBar.progressTintColor = UIColor(red:0.96, green:0.13, blue:0.18, alpha:1.0)
                }
            } else {
                cell.titleLabel.text = nil
                cell.detailLabel.text = nil
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch adjustedSection(index: indexPath.section) {
        case 0...1:
            return 100
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch adjustedSection(index: indexPath.section) {
        case 0:
            linkAccount()
        case 1...2:
            self.performSegue(withIdentifier: "ShowTransactions", sender: self)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: Private
    
    @objc private func refreshTable(_ refreshControl: UIRefreshControl) {
        transactionController.updateCategoriesFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            }
            
            if let error = error {
                return NSLog("\(error)")
            }
        }
    }
    
    private func linkAccount() {
        guard let publicKey = ProcessInfo.processInfo.environment["PLAID_PUBLIC_KEY"] else {
            return NSLog("No public key found!")
        }
        let linkConfiguration = PLKConfiguration(key: publicKey, env: .sandbox, product: [.auth, .transactions, .identity])
        linkConfiguration.webhook = URL(string: "https://lambda-budget-blocks.herokuapp.com/plaid/webhook")!
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: self)
        present(linkViewController, animated: true)
    }
    
    @objc private func logout() {
        networkingController.logout()
        TransactionController().clearStoredTransactions(context: CoreDataStack.shared.mainContext)
        performSegue(withIdentifier: "AnimatedLogin", sender: self)
    }
    
    private func updateBalances() {
        guard let amounts = transactionsFRC.fetchedObjects?.map({ $0.amount }) else {
            incomeLabel.text = "+$0"
            expensesLabel.text = "-$0"
            balanceLabel.text = "$0"
            return
        }
        let positiveTransactions = amounts.filter({ $0 > 0 })
        let negativeTransactions = amounts.filter({ $0 < 0 })
        
        let expenses = positiveTransactions.reduce(0, +)
        let income = negativeTransactions.reduce(0, +) * -1
        
        incomeLabel.text = "+$\(income.currency)"
        expensesLabel.text = "-$\(expenses.currency)"
        balanceLabel.text = "$\((income - expenses).currency)"
    }
    
    private func adjustedSection(index: Int) -> Int {
        return index + (networkingController.linkedAccount ? 1 : 0)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let welcomeVC = segue.destination as? WelcomeViewController {
            welcomeVC.networkingController = networkingController
        } else if let transactionsVC = segue.destination as? TransactionsViewController {
            transactionsVC.networkingController = networkingController
            transactionsVC.transactionController = transactionController
            
            if let indexPath = tableView.indexPathForSelectedRow,
                adjustedSection(index: indexPath.section) == 2 {
                transactionsVC.category = categoriesFRC.fetchedObjects?[indexPath.row]
            }
        }
    }

}

// MARK: Plaid Link view delegate

extension DashboardTableViewController: PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        print("Link successful. Public token: \(publicToken)")
        networkingController.tokenExchange(publicToken: publicToken) { error in
            if let error = error {
                return NSLog("Error exchanging token: \(error)")
            }
            
            self.networkingController.setLinked()
            DispatchQueue.main.async {
                self.tableView.reloadData()
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

// MARK: Fetched results controller delegate

extension DashboardTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateBalances()
    }
}
