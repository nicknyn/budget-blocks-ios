//
//  CensusData+Convenience.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import CoreData



extension CensusData {
    var censusDataRepresentation: CensusDataRepresentation {
        guard let city = city else { fatalError() }
        return CensusDataRepresentation(city: city,
                                        personal: personal,
                                        food: food,
                                        debt: debt,
                                        income: income,
                                        giving: giving,
                                        housing: housing,
                                        transportation: transportation,
                                        transfer: transfer,
                                        savings: savings)
    }
    
    @discardableResult convenience init(city: String,
                                        personal: Double,
                                        food: Double,
                                        debt: Double,
                                        income: Double,
                                        giving: Double,
                                        housing: Double,
                                        transportation: Double,
                                        transfer: Double,
                                        savings: Double,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context:context)
        self.city                 = city
        self.personal             = personal
        self.food                 = food
        self.debt                 = debt
        self.income               = income
        self.giving               = giving
        self.housing              = housing
        self.transportation       = transportation
        self.transfer             = transfer
        self.savings              = savings
        
    }
    
    
    
    
    @discardableResult convenience init?(censusRepresentation: CensusDataRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(city  : censusRepresentation.city,
                  personal: censusRepresentation.personal,
                  food    : censusRepresentation.food,
                  debt: censusRepresentation.debt,
                  income    : censusRepresentation.income,
                  giving: censusRepresentation.giving,
                  housing: censusRepresentation.housing,
                  transportation: censusRepresentation.transportation,
                  transfer : censusRepresentation.transfer,
                  savings :censusRepresentation.savings,
                  context : context)
        
    }
}
