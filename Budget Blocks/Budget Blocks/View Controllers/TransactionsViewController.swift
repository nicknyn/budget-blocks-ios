//
//  TransactionsViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

class TransactionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var networkingController: NetworkingController!
    var transactionController: TransactionController!
    var category: TransactionCategory?
    let dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        return dateFormatter
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Transaction> = {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
            NSSortDescriptor(key: "transactionID", ascending: true)
        ]
        
        if let category = category {
            let predicate = NSPredicate(format: "category == %@", category)
            fetchRequest.predicate = predicate
        }
        
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
        
        if let categoryName = category?.name {
            title = categoryName
        }
        
        transactionController.updateTransactionsFromServer(context: CoreDataStack.shared.mainContext) { message, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertAndReturn(title: "An error has occurred.", message: "There was an error fetching your transactions.")
                }
                return error.log()
            }
            
            guard let message = message else { return }
            if message == "No access_Token found for that user id provided" {
                DispatchQueue.main.async {
                    self.alertAndReturn(title: "No linked accounts", message: "Please link a bank account first")
                }
            } else if message == "insertion process hasn't started"
                || message == "we are inserting your data" {
                DispatchQueue.main.async {
                    self.alertAndReturn(title: "Try again in a moment", message: "We're working on fetching your transactions. Please try again in a moment.")
                }
            } else {
                DispatchQueue.main.async {
                    self.alertAndReturn(title: "An error has occurred.", message: "There was an error fetching your transactions.")
                }
                NSLog("Message: \(message)")
            }
        }
    }
    
    private func alertAndReturn(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            // Only return if there are no locally-stored transactions
            if self.fetchedResultsController.fetchedObjects?.count == 0 {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        var predicates: [NSPredicate] = []
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        switch sender.selectedSegmentIndex {
        case 0:
            predicates.append(NSPredicate(format: "amount > 0"))
        case 2:
            predicates.append(NSPredicate(format: "amount < 0"))
        default:
            break
        }
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        try? fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
}

// MARK: Table view data source and delegate

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let uiCell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        guard let cell = uiCell as? TransactionTableViewCell else { return uiCell }
        
        let transaction = fetchedResultsController.object(at: indexPath)
        cell.descriptionLabel.text = transaction.name
        cell.amountLabel.text = "$\(transaction.amount.currency)"
        
        if let category = transaction.category?.name {
            cell.categoryLabel.text = category
        }
        
        if let date = transaction.date {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }
        
        cell.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        
        return cell
    }
}

// MARK: Fetched results controller delegate

extension TransactionsViewController: NSFetchedResultsControllerDelegate {
    
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
