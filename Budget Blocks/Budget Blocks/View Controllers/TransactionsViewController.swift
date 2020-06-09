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
    
    var networkingController: NetworkingController!
    var transactionController: TransactionController!
    var category: TransactionCategory?
    
    @IBOutlet weak private var tableView: UITableView!
    private let dateFormatter = DateFormatter()
    private let loadingGroup = DispatchGroup()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<DataScienceTransaction> = {
        let fetchRequest: NSFetchRequest<DataScienceTransaction> = DataScienceTransaction.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
          ]
        
        
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

    //MARK:- Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        dateFormatter.dateFormat = "MM/dd/YYYY"
       
        if let categoryName = category?.name {
            title = categoryName
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
        print(fetchedResultsController.fetchedObjects?.count)
        return fetchedResultsController.fetchedObjects?.count ?? 0

      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let uiCell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        guard let cell = uiCell as? TransactionTableViewCell else { return uiCell }
        
        let transaction = fetchedResultsController.object(at: indexPath)

        cell.amountLabel.text      = String(transaction.amount) + "$"
        cell.descriptionLabel.text = transaction.name
//
        let ac = transaction.category as! [String]
        cell.categoryLabel.text    = ac.joined()
        cell.dateLabel.text        = transaction.date?.description
        cell.amountLabel.textColor = transaction.amount < 0 ?  UIColor.red : UIColor.link
        
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
            guard let indexPath    = indexPath,
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
