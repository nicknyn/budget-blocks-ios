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
    
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var incomeLabel: UILabel!
    @IBOutlet private weak var expensesLabel: UILabel!
    @IBOutlet private weak var totalBudgetLabel: UILabel!
    
    // MARK: Properties
    
    let networkingController = NetworkingController()
    let transactionController = TransactionController()
    var newTransactionController: TransactionController?
    var newCategories: [TransactionCategory] = []
    var loadingGroup = DispatchGroup()
    
    private(set) lazy var transactionsFRC: NSFetchedResultsController<Transaction> = {
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
    
    private(set) lazy var categoriesFRC: NSFetchedResultsController<TransactionCategory> = {
        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "budget", ascending: false)]
        
        let predicate = NSPredicate(format: "transactions.@count > 0 OR budget > 0")
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
            
    
    var categoriesWithBudget: [TransactionCategory] {
        categoriesFRC.fetchedObjects?.filter({ $0.budget > 0 }) ?? []
    }
    
    //MARK:- Life Cycle-
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // this is adding the observer
        NotificationCenter.default.addObserver(self, selector: #selector(refreshHelper), name: .refreshInfo, object: nil)
        transactionController.networkingController = networkingController
        
        updateBalances()
        updateRemainingBudget()
        
        let largeTitleFontSize = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.largeTitle).pointSize
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Exo-Regular", size: largeTitleFontSize)!]
        
        // Temporary logout button until the profile page is set up
        let logoutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem = logoutButton
        
        networkingController.loginWithKeychain { success in
            if success {
                DispatchQueue.main.async {
                    self.setUpViews()
                }
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "InitialLogin", sender: self)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    
    //MARK:-
    @IBAction func goToCustomeView(_ sender: Any) {
        performSegue(withIdentifier: "CustomCat", sender: self)
      }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch adjustedSection(index: section) {
        case 2:
            let categoriesCount = categoriesFRC.fetchedObjects?.count ?? 0
            return categoriesCount + (categoriesWithBudget.count == 0).int
        default:
            return 1 + networkingController.manualAccount.int * 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let adjustedSection = self.adjustedSection(index: indexPath.section)
        
        switch adjustedSection {
        case 0...1,
             2 where indexPath.row == 0 && categoriesWithBudget.count == 0:
            let uiCell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath)
            guard let cell = uiCell as? DashboardTableViewCell else { return uiCell }
            
            let completedCell = setCellTextAndIamge(cell: cell, adjustedSection: adjustedSection, row: indexPath.row)
            
            return completedCell
            
        default:
            let cell = CategoryTableViewCell()
            let catCell = setCategoryCells(cell: cell, indexPath: indexPath, adjustedSection: adjustedSection)
            return catCell
        }
    }
    
    func setCategoryCells(cell: CategoryTableViewCell, indexPath: IndexPath, adjustedSection: Int ) -> CategoryTableViewCell {
        let uiCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        guard let cell = uiCell as? CategoryTableViewCell else { return uiCell as! CategoryTableViewCell }
        
        cell.titleLabel.setApplicationTypeface()
        cell.detailLabel.font = UIFont(name: "Exo-Regular", size: 12.0)
        
        let index = indexPath.row - (categoriesWithBudget.count == 0).int
        if let category = categoriesFRC.fetchedObjects?[index] {
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
    
    func setCellTextAndIamge(cell: DashboardTableViewCell, adjustedSection: Int, row: Int) -> DashboardTableViewCell {
        
        var cellText: String
        var cellImage: UIImage?
        
        switch adjustedSection {
        case 0:
            cellText = "Connect your bank with Plaid"
            cellImage = UIImage(named: "plaid-logo-icon")
        case 1:
            switch row {
            case 0:
                cellText = "View Transactions"
                cellImage = UIImage(named: "budget")
                
            case 1:
                cellText = "Add an expense"
                cellImage = UIImage(named: "minus-icon")
                
            default:
                cellText = "Add income"
                cellImage = UIImage(named: "plus-icon")
                
            }
        default:
            cellText = "Create a budget"
            cellImage = UIImage(named: "budget")
        }
        cell.titleLabel.text = cellText
        cell.rightImageView.image = cellImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch adjustedSection(index: indexPath.section) {
        case 0...1,
             2 where indexPath.row == 0 && categoriesWithBudget.count == 0:
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
        case 1 where indexPath.row == 0:
            self.performSegue(withIdentifier: "ShowTransactions", sender: self)
        case 1:
            self.performSegue(withIdentifier: "AddTransaction", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        case 2 where indexPath.row == 0 && categoriesWithBudget.count == 0:
            self.performSegue(withIdentifier: "CreateBudget", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            viewBudget(forRowAt: indexPath)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK:- Private-
    
    private func setUpViews() {
        transactionController.updateCategoriesFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            error?.log()
            DispatchQueue.main.async {
                self.createInitalBudget()
            }
        }
        transactionController.updateTransactionsFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            error?.log()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshHelper() {
        print("refreshHelper is being called!")
        transactionController.updateTransactionsFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            error?.log()
        }
        transactionController.updateCategoriesFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            error?.log()
        }
    }

    
    @objc private func refreshTable(_ refreshControl: UIRefreshControl) {
        transactionController.updateTransactionsFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            error?.log()
        }
        transactionController.updateCategoriesFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            }
            
            error?.log()
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
        
        for category in categoriesWithBudget {
            totalBudget += category.budget
            totalSpending += transactionController.getTotalSpending(for: category)
        }
        
        balanceLabel.text = "$\(totalSpending.currency)"
        totalBudgetLabel.text = "$\(totalBudget.currency)"
    }
    
    private func adjustedSection(index: Int) -> Int {
        // Sections:
        // 0. Connect bank acount with Plaid
        // 1. View Transactions
        // 2. List of categories
        return index + networkingController.accountSetUp.int
    }
    
    private func viewBudget(forRowAt indexPath: IndexPath) {
        let alertMessage = "Would you like to view transactions of this budget or create a new budget?"
        let actionSheet = UIAlertController(title: nil, message: alertMessage, preferredStyle: .actionSheet)
        
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
        
        let editBudget = UIAlertAction(title: "Edit Budget", style: .default) { _ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "CreateBudget", sender: self)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        actionSheet.addAction(cancel)
        actionSheet.addAction(viewTransactions)
        actionSheet.addAction(newBudget)
        actionSheet.addAction(editBudget)
        
        actionSheet.pruneNegativeWidthConstraints()
        
        present(actionSheet, animated: true)
    }
    
    private func createInitalBudget() {
        guard !networkingController.accountSetUp else { return }
        performSegue(withIdentifier: "Onboarding", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let welcomeVC = segue.destination as? WelcomeViewController {
            welcomeVC.networkingController = networkingController
            welcomeVC.delegate = self
        } else if let transactionsVC = segue.destination as? TransactionsViewController {
            transactionsVC.networkingController = networkingController
            transactionsVC.transactionController = transactionController
            
            if let indexPath = tableView.indexPathForSelectedRow,
                adjustedSection(index: indexPath.section) == 2 {
                let index = indexPath.row - (categoriesWithBudget.count == 0).int
                transactionsVC.category = categoriesFRC.fetchedObjects?[index]
            }
        } else if let navigationVC = segue.destination as? UINavigationController {
            if let blocksVC = navigationVC.viewControllers.first as? BlocksViewController {
                blocksVC.transactionController = transactionController
                blocksVC.budgets = categoriesWithBudget.map({ ($0, $0.budget) })
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    let index = indexPath.row - (categoriesWithBudget.count == 0).int
                    if index >= 0,
                        let selectedCategory = categoriesFRC.fetchedObjects?[index],
                        selectedCategory.budget == 0 {
                        blocksVC.budgets.append((selectedCategory, 0))
                    }
                }
            } else if let onboardingVC = navigationVC.viewControllers.first as? OnboardingViewController {
                onboardingVC.transactionController = transactionController
                onboardingVC.networkingController = networkingController
                onboardingVC.delegate = self
            } else if let createTransactionVC = navigationVC.viewControllers.first as? CreateTransactionViewController {
                createTransactionVC.transactionController = transactionController
                
                if let indexPath = tableView.indexPathForSelectedRow,
                    indexPath.row == 2 {
                    createTransactionVC.income = true
                }
            }
        }
        
        if let customVC = segue.destination as? CustomCategoriesTableViewController {
            customVC.transactionController = transactionController
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

// MARK: Login view controller delegate

extension DashboardTableViewController: LoginViewControllerDelegate {
    func loginSuccessful() {
        let dismissGroup = DispatchGroup()
        
        dismissGroup.enter()
        dismiss(animated: true) {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    dismissGroup.leave()
                }
            }
        }
        
        transactionController.updateCategoriesFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            error?.log()
            dismissGroup.notify(queue: .main, execute: {
                self.createInitalBudget()
            })
        }
    }
}

// MARK: Onboarding view controller delegate

extension DashboardTableViewController: OnboardingViewControllerDelegate {
    func accountConnected() {
        transactionController.updateTransactionsFromServer(context: CoreDataStack.shared.mainContext) { _, error in
            error?.log()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // comment for commit 
}
