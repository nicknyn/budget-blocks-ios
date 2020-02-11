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
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Properties
    
    var transactionController: TransactionController?
    var selectedCategories: [TransactionCategory] = []
    var budgets: [Int: Int64] = [:]
    var categoriesAreSet: Bool = false
    
    lazy var fetchedResultsController: NSFetchedResultsController<TransactionCategory> = {
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

        tableView.allowsSelection = !categoriesAreSet
        
        let titleText = categoriesAreSet ? "Save" : "Continue"
        nextButton.setTitle(titleText, for: .normal)
        
        let daybreakBlue = UIColor(red: 0.094, green: 0.565, blue: 1, alpha: 1)
        nextButton.layer.backgroundColor = daybreakBlue.cgColor
        nextButton.layer.cornerRadius = 4
        nextButton.setTitleColor(.white, for: .normal)
        if let buttonFontSize = nextButton.titleLabel?.font.pointSize {
            nextButton.titleLabel?.font = UIFont(name: "Exo-Regular", size: buttonFontSize)
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: Private
    
    @objc func adjustForKeyboard(notification: Notification) {
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
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard categoriesAreSet else { return }
        
        for (index, category) in selectedCategories.enumerated() {
            let budget = budgets[index] ?? 0
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
            blocksVC.selectedCategories = selectedCategories
            blocksVC.categoriesAreSet = true
        }
    }

}

// MARK: Table view data source and delegate

extension BlocksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoriesAreSet {
            return selectedCategories.count
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
            category = selectedCategories[indexPath.row]
            guard let budgetCell = cell as? BudgetTableViewCell else { return cell }
            titleLabel = budgetCell.titleLabel
            
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
            selectedCategories.contains(category) {
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
        
        if selectedCategories.contains(category) {
            selectedCategories.removeAll(where: { $0 == category })
            cell?.accessoryType = .none
        } else {
            selectedCategories.append(category)
            cell?.accessoryType = .checkmark
        }
    }
}

// MARK: Text field delegate

extension BlocksViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let budgetString = textField.text,
            let budgetFloat = Float(budgetString) else {
                textField.text = "\(budgets[textField.tag] ?? 0)"
                return
        }
        let budget = Int64(budgetFloat * 100)
        budgets[textField.tag] = budget
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
