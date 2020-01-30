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
    let transactionController = TransactionController()

    override func viewDidLoad() {
        super.viewDidLoad()

        transactionController.networkingController = networkingController
        transactionController.updateTransactionsFromServer(context: CoreDataStack.shared.mainContext) { error in
            if let error = error {
                return NSLog("\(error)")
            }
            
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            let transactions = try! CoreDataStack.shared.mainContext.fetch(fetchRequest)
            print(transactions.map({ $0.amount }))
        }
    }

}
