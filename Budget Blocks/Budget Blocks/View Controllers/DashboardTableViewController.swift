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
import OktaOidc
import OktaAuthNative
import SVProgressHUD

@objcMembers class DashboardTableViewController: UITableViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak private var balanceLabel: UILabel!
    @IBOutlet weak private var incomeLabel: UILabel!
    @IBOutlet weak private var expensesLabel: UILabel!
    @IBOutlet weak private var totalBudgetLabel: UILabel!
    
    // MARK: Properties
    
    let networkingController = NetworkingController()
    let transactionController = TransactionController()
    var newTransactionController: TransactionController?
    var newCategories: [TransactionCategory] = []
    var loadingGroup = DispatchGroup()
    private var userID: Int?
    
    var oktaOidc: OktaOidc?
    var stateManager: OktaOidcStateManager?
    var successStatus: OktaAuthStatus?
    
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
        return categoriesFRC.fetchedObjects?.filter({ $0.budget > 0 }) ?? []
    }
       static let user = User(context: CoreDataStack.shared.mainContext)
    //MARK:- Life Cycle-
  
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("THIS IS status \(successStatus!)")
        
        
                DashboardTableViewController.user.name =
                    [(successStatus?.model.embedded?.user?.profile?.firstName)!,  (successStatus?.model.embedded?.user?.profile?.lastName)!].joined(separator: " ")
                DashboardTableViewController.user.email = successStatus?.model.embedded?.user?.profile?.login
                try? CoreDataStack.shared.mainContext.save()
        
                guard let oidcClient = self.createOidcClient() else { return }
                oidcClient.authenticate(withSessionToken: (successStatus?.model.sessionToken!)!) { [weak self] (stateManager, error) in
                    print("Access token is \(stateManager?.accessToken!)")
                    NetworkingController.shared.registerUserToDatabase(user: DashboardTableViewController.user.userRepresentation!, accessToken: (stateManager!.accessToken!)) { (user, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        self?.userID = user?.data.id
                    }
                }
                tableView.reloadData()
        
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
            guard let userID = userID else { return }
            NetworkingController.shared.getAccessTokenFromUserId(userID: userID) { (result) in
                switch result {
                    case .success(let bankInfos):
                        print(bankInfos.data.first!.accessToken)
                    case .failure(let error):
                    print(error)
                }
            }
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
    
     func refreshHelper() {
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
        guard let publicKey       = ProcessInfo.processInfo.environment["PLAID_PUBLIC_KEY"] else { return NSLog("No public key found!") }
        let linkConfiguration     = PLKConfiguration(key: publicKey, env: .sandbox, product: [.auth, .transactions, .identity])
        linkConfiguration.webhook = URL(string: "https://lambda-budget-blocks.herokuapp.com/plaid/webhook")!
        let linkViewController    = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: self)
        present(linkViewController, animated: true)
    }
    
    @objc private func logout() {
//        networkingController.logout()
        tabBarController?.navigationController?.popViewController(animated: true)
//        TransactionController().clearStoredTransactions(context: CoreDataStack.shared.mainContext)
//        performSegue(withIdentifier: "AnimatedLogin", sender: self)
//        self.tabBarController?.navigationController?.popViewController(animated: true)
////        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
//        print("WANT TO LOG OUT")
//        if let oidcStateManager = self.stateManager {
//            let oidcClient = self.createOidcClient()
//
//        let oidcClient = self.createOidcClient()
//        oidcClient?.signOutOfOkta(<#T##authStateManager: OktaOidcStateManager##OktaOidcStateManager#>, from: <#T##UIViewController#>, callback: <#T##((Error?) -> Void)##((Error?) -> Void)##(Error?) -> Void#>)
//            oidcClient!.signOutOfOkta(oidcStateManager, from: self, callback: { [weak self] error in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//
//                    print("HEE")
//
////                    self?.flowCoordinatorDelegate?.onLoggedOut()
//                }
//            })
//        }
        
//        guard let oktaOidc = self.oktaOidc, let stateManager = self.stateManager else { return }
//        oktaOidc.signOutOfOkta(stateManager, from: self) { [weak self ] error in
//            if let error = error {
//                let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self?.present(ac, animated: true, completion: nil)
//                return
//            }
//            self?.stateManager?.clear()
//            self?.tabBarController?.navigationController?.popViewController(animated: true)
//        }
    }
    
    private func updateBalances() {
        guard let amounts        = transactionsFRC.fetchedObjects?.map({ $0.amount }) else {
            incomeLabel.text     = "+$0"
            expensesLabel.text   = "-$0"
            return
        }
        let positiveTransactions = amounts.filter({ $0 > 0 })
        let negativeTransactions = amounts.filter({ $0 < 0 })
        
        let expenses             = positiveTransactions.reduce(0, +)
        let income               = negativeTransactions.reduce(0, +) * -1
        
        incomeLabel.text         = "+$\(income.currency)"
        expensesLabel.text       = "-$\(expenses.currency)"
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
        print("USER ID IS \(userID)")
   
        NetworkingController.shared.sendPlaidPublicTokenToServerToGetAccessToken(publicToken: publicToken, userID: userID!) { (error) in
            print(error?.localizedDescription)
            // POST the database
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

private extension DashboardTableViewController {
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
