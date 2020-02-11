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
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "budget", ascending: false)]
        
        let predicate = NSPredicate(format: "transactions.@count > 0")
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
    
    var categoriesWithBudget: [TransactionCategory]? {
        categoriesFRC.fetchedObjects?.filter({ $0.budget > 0 })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBalances()
        updateRemainingBudget()
        
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
            let categoriesCount = categoriesFRC.fetchedObjects?.count ?? 0
            return categoriesCount > 0 ? categoriesCount : 1
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
                cellText = "View Transactions"
                cellImage = UIImage(named: "budget")
            }
            cell.titleLabel.text = cellText
            cell.rightImageView.image = cellImage
            
            return cell
        default:
            if categoriesFRC.fetchedObjects?.count ?? 0 == 0 {
                let uiCell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath)
                guard let cell = uiCell as? DashboardTableViewCell else { return uiCell }
                
                cell.titleLabel.text = "Create a budget"
                cell.rightImageView.image = UIImage(named: "budget")
                
                return cell
            } else {
                let uiCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
                guard let cell = uiCell as? CategoryTableViewCell else { return uiCell }
                
                cell.titleLabel.setApplicationTypeface()
                cell.detailLabel.font = UIFont(name: "Exo-Regular", size: 12.0)
                
                if let category = categoriesFRC.fetchedObjects?[indexPath.row] {
                    cell.titleLabel.text = category.name
                    var sum: Int64 = 0
                    for transaction in category.transactions ?? [] {
                        guard let transaction = transaction as? Transaction else { continue }
                        sum += transaction.amount
                    }
                    var budgetString = "$\(sum.currency)"
                    
                    if category.budget > 0 {
                        budgetString += " / $\(category.budget.currency)"
                        
                        let progress = Float(sum) / Float(category.budget)
                        cell.progressBar.progress = progress
                        if progress < 0.8 {
                            cell.progressBar.progressTintColor = UIColor(red:0.32, green:0.77, blue:0.10, alpha:1.0)
                        } else {
                            cell.progressBar.progressTintColor = UIColor(red:0.96, green:0.13, blue:0.18, alpha:1.0)
                        }
                    } else {
                        cell.progressBar.progress = 0
                    }
                    
                    cell.detailLabel.text = budgetString
                } else {
                    cell.titleLabel.text = nil
                    cell.detailLabel.text = nil
                }
                
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch adjustedSection(index: indexPath.section) {
        case 0...1,
             2 where categoriesFRC.fetchedObjects?.count ?? 0 == 0:
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch adjustedSection(index: indexPath.section) {
        case 0:
            linkAccount()
        case 1:
            self.performSegue(withIdentifier: "ShowTransactions", sender: self)
        case 2 where categoriesFRC.fetchedObjects?.count ?? 0 == 0:
            self.performSegue(withIdentifier: "CreateBudget", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            viewBudget(forRowAt: indexPath)
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
            return
        }
        let positiveTransactions = amounts.filter({ $0 > 0 })
        let negativeTransactions = amounts.filter({ $0 < 0 })
        
        let expenses = positiveTransactions.reduce(0, +)
        let income = negativeTransactions.reduce(0, +) * -1
        
        incomeLabel.text = "+$\(income.currency)"
        expensesLabel.text = "-$\(expenses.currency)"
    }
    
    private func updateRemainingBudget() {
        var totalBudget: Int64 = 0
        var totalSpending: Int64 = 0
        
        //let categories = categoriesWithBudget
        
        for category in categoriesWithBudget ?? [] {
            totalBudget += category.budget
            for transaction in category.transactions ?? [] {
                guard let transaction = transaction as? Transaction else { continue }
                totalSpending += transaction.amount
            }
        }
        
        balanceLabel.text = "$\((totalBudget - totalSpending).currency)"
    }
    
    private func adjustedSection(index: Int) -> Int {
        return index + (networkingController.linkedAccount ? 1 : 0)
    }
    
    private func viewBudget(forRowAt indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: nil, message: "Would you like to view transactions of this budget or create a new budget?", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        let viewTransactions = UIAlertAction(title: "View Transactions", style: .default) { _ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowTransactions", sender: self)
            }
        }
        let newBudget = UIAlertAction(title: "Create Budget", style: .default) { _ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "CreateBudget", sender: self)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        actionSheet.addAction(cancel)
        actionSheet.addAction(viewTransactions)
        actionSheet.addAction(newBudget)
        
        actionSheet.pruneNegativeWidthConstraints()
        
        present(actionSheet, animated: true)
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
        } else if let navigationVC = segue.destination as? UINavigationController,
            let blocksVC = navigationVC.viewControllers.first as? BlocksViewController {
            blocksVC.transactionController = transactionController
            if let budgets = categoriesWithBudget?.map({ ($0, $0.budget) }) {
                blocksVC.budgets = budgets
            }
            if let indexPath = tableView.indexPathForSelectedRow,
                let selectedCategory = categoriesFRC.fetchedObjects?[indexPath.row],
                selectedCategory.budget == 0 {
                blocksVC.budgets.append((selectedCategory, 0))
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
        updateRemainingBudget()
        
        switch controller {
        case transactionsFRC:
            updateBalances()
        case categoriesFRC:
            tableView.reloadData()
        default:
            break
        }
    }
}
