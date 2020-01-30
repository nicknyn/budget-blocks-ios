//
//  TransactionController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

class TransactionController {
    
    func createTransaction(transactionID: String, amount: Int16, date: Date, context: NSManagedObjectContext) {
        Transaction(transactionID: transactionID, amount: amount, date: date, context: context)
        CoreDataStack.shared.save(context: context)
    }
    
    func deleteTransaction(transaction: Transaction, context: NSManagedObjectContext) {
        context.delete(transaction)
        CoreDataStack.shared.save(context: context)
    }
    
}
