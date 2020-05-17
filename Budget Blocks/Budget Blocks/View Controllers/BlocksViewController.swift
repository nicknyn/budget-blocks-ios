//
//  BlocksViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

class BlocksViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var promptLabel: UILabel!
    @IBOutlet private weak var totalStackView: UIStackView!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var totalSubtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK:- Properties
    
    var transactionController: TransactionController?
    var budgets: [(category: TransactionCategory, budget: Int64)] = []
    var categoriesAreSet: Bool = false
    
   private(set) lazy var fetchedResultsController: NSFetchedResultsController<TransactionCategory> = {
        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
        
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
        
        setUpViews()
        updateViews()
    }
    
    // MARK:- Private
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    private func setUpViews() {
        tableView.allowsSelection = !categoriesAreSet
        
        if !categoriesAreSet {
            titleLabel.text = "Choose spending blocks"
            promptLabel.text = "Choose which categories you would like to set budgets for."
            navigationItem.setHidesBackButton(true, animated: false)
        } else {
            titleLabel.text = "Budgets"
            promptLabel.text = "Assign the value you want in each selected category."
        }
        
        totalStackView.isHidden = !categoriesAreSet
        
        let titleText = categoriesAreSet ? "Save" : "Continue"
        nextButton.setTitle(titleText, for: .normal)
        
        let daybreakBlue = UIColor(red: 0.094, green: 0.565, blue: 1, alpha: 1)
        nextButton.layer.backgroundColor = daybreakBlue.cgColor
        nextButton.layer.cornerRadius = 4
        nextButton.setTitleColor(.white, for: .normal)
        if let buttonFontSize = nextButton.titleLabel?.font.pointSize {
            nextButton.titleLabel?.font = UIFont(name: "Exo-Regular", size: buttonFontSize)
        }
        
        promptLabel.setApplicationTypeface()
        totalLabel.setApplicationTypeface()
        totalSubtitleLabel.setApplicationTypeface()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func updateViews() {
        let total = budgets.map({ $0.budget }).reduce(0, +)
        totalLabel.text = "$" + total.currency
    }
    
    // MARK:- Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard categoriesAreSet else { return }
        
        for (category, budget) in budgets {
            //let budget = budgets[index] ?? 0
            transactionController?.setCategoryBudget(category: category, budget: budget, completion: { error in
                if let error = error {
                    return NSLog("Error setting \(category.name ?? "category") budget: \(error)")
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !categoriesAreSet
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let blocksVC = segue.destination as? BlocksViewController {
            blocksVC.transactionController = transactionController
            blocksVC.budgets = budgets
            blocksVC.categoriesAreSet = true
            if navigationItem.rightBarButtonItem == nil {
                blocksVC.navigationItem.rightBarButtonItem = nil
            }
        }
    }

}

// MARK: Table view data source and delegate

extension BlocksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoriesAreSet {
            return budgets.count
        } else {
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = categoriesAreSet ? "BudgetCell" : "CategoryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let category: TransactionCategory
        let titleLabel: UILabel?
        if categoriesAreSet {
            category = budgets[indexPath.row].category
            guard let budgetCell = cell as? BudgetTableViewCell else { return cell }
            titleLabel = budgetCell.titleLabel
                        
            let budget = budgets[indexPath.row].budget
            if budget > 0 {
                budgetCell.textField.text = "$\(budget.currency)"
            }
            budgetCell.textField.tag = indexPath.row
            budgetCell.textField.delegate = self
        } else {
            category = fetchedResultsController.object(at: indexPath)
            titleLabel = cell.textLabel
        }
        titleLabel?.text = category.name
        
        if let textSize = titleLabel?.font.pointSize {
            titleLabel?.font = UIFont(name: "Exo-Regular",size: textSize)
        }
        
        if !categoriesAreSet,
            budgets.contains(where: { $0.category == category }) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        let category = fetchedResultsController.object(at: indexPath)
        
        if budgets.contains(where: { $0.category == category }) {
            budgets.removeAll(where: { $0.category == category })
            cell?.accessoryType = .none
        } else {
            budgets.append((category, category.budget))
            cell?.accessoryType = .checkmark
        }
    }
}

// MARK: Text field delegate

extension BlocksViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text?.first == "$" {
            textField.text?.removeFirst()
            
            if textField.text?.last == "0", textField.text?.dropLast().last == "0" {
                textField.text?.removeLast(3)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var budgetFloat: Float?
        
        if let budgetString = textField.text,
            !budgetString.isEmpty {
            budgetFloat = Float(budgetString)
        } else {
            budgetFloat = 0
        }
        
        if let budgetFloat = budgetFloat {
            let budget = Int64(budgetFloat * 100)
            budgets[textField.tag].budget = budget
            
            if budget > 0 {
                textField.text = "$\(budget.currency)"
            } else {
                textField.text = nil
            }
        } else {
            // If the text inputted was not valid, set it back to the last known valud budget
            textField.text = "$\(budgets[textField.tag].budget.currency)"
        }
        
        updateViews()
    }
}

// MARK: Fetched results controller delegate

extension BlocksViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
    }
    
}
