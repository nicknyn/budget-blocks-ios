//
//  TransactionController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

class TransactionController {
    
    var networkingController: NetworkingController?
    
    func createTransaction(transactionID: String, name: String, amount: Int16, date: Date, context: NSManagedObjectContext) {
        Transaction(transactionID: transactionID, name: name, amount: amount, date: date, context: context)
        CoreDataStack.shared.save(context: context)
    }
    
    func deleteTransaction(transaction: Transaction, context: NSManagedObjectContext) {
        context.delete(transaction)
        CoreDataStack.shared.save(context: context)
    }
    
    func updateTransactionsFromServer(context: NSManagedObjectContext, completion: @escaping (Error?) -> Void) {
        networkingController?.fetchTransactionsFromServer(completion: { json, error in
            if let error = error {
                return completion(error)
            }
            
            guard let transactions = json?["transactions"].array else {
                NSLog("Transaction fetch response did not contain transactions")
                if let message = json?["message"].string {
                    if message == "No access_Token found for that user id provided" {
                        // TODO: Alert the user
                        print("User needs to link a bank account first!")
                    } else {
                        NSLog("Message: \(message)")
                    }
                }
                return completion(nil)
            }
            
            do {
                let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                let existingTransactions = try context.fetch(fetchRequest)
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [
                    .withYear,
                    .withMonth,
                    .withDay
                ]
                
                for transactionJSON in transactions {
                    guard let transactionID = transactionJSON["transaction_id"].string,
                        let name = transactionJSON["name"].string,
                        let amount = transactionJSON["amount"].int16,
                        let dateString = transactionJSON["date"].string,
                        let date = dateFormatter.date(from: dateString) else { continue }
                    
                    if let existingTransaction = existingTransactions.first(where: { $0.transactionID == transactionID }) {
                        existingTransaction.name = name
                        existingTransaction.amount = amount
                        existingTransaction.date = date
                    } else {
                        Transaction(transactionID: transactionID, name: name, amount: amount, date: date, context: context)
                    }
                }
                
                CoreDataStack.shared.save(context: context)
                completion(nil)
            } catch {
                completion(error)
            }
        })
    }
    
    func clearStoredTransactions(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        do {
            let allTransactions = try context.fetch(fetchRequest)
            for transaction in allTransactions {
                context.delete(transaction)
            }
            CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error fetching transactions for deletion: \(error)")
        }
    }
    
}
