//
//  DataScienceTransactionRepresentation.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/2/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import CoreData


struct DataScienceTransactionRepresentations : Codable {
    let transactions : [DataScienceTransactionRepresentation]
}
struct DataScienceTransactionRepresentation : Codable {
    let amount: Double
    let location: Location
    let date: String
    let name: String
    let category: [String]
    let transactionID: String
    
    enum CodingKeys: String,CodingKey {
        case amount   = "amount"
        case location = "location"
        case date     = "date"
        case name     = "name"
        case category = "budget_blocks_category"
        case transactionID = "transaction_id"
    }
}

extension DataScienceTransaction {
    
    var dataScienceTransactionRepresentation : DataScienceTransactionRepresentation {
        guard let location = location as? Location else { preconditionFailure("No data")}
        guard let date     = date,
            let name     = name,
            let category = category as? [String],
            let transactionID = transactionID
            else { preconditionFailure("No data") }
        return DataScienceTransactionRepresentation(amount: amount,
                                                    location: location,
                                                    date: date,
                                                    name: name, category: category,
                                                    transactionID: transactionID)
    }
    
    @discardableResult convenience init(amount: Double,
                                        location: Location,
                                        date: String,
                                        name: String,
                                        category: [String],
                                        transactionID: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context:context)
        self.amount           = amount
        self.location         = location
        self.date             = date
        self.name             = name
        self.category         = category as NSObject
        self.transactionID    = transactionID
    }
    
    
    
    
    @discardableResult convenience init?(dataScienceTransactionRepresentation: DataScienceTransactionRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
       
        self.init(amount  : dataScienceTransactionRepresentation.amount,
                  location: dataScienceTransactionRepresentation.location,
                  date    : dataScienceTransactionRepresentation.date,
                  name    : dataScienceTransactionRepresentation.name,
                  category: dataScienceTransactionRepresentation.category,
                  transactionID: dataScienceTransactionRepresentation.transactionID,
                  context : context)
        
    }
}
