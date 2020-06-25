//
//  Goal+Convenience.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/23/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import CoreData

extension Goal {
  var goalRepresentation: GoalRepresentation {
    return GoalRepresentation(id: Int(id),
                              food: food,
                              housing: housing,
                              personal: personal,
                              income: income,
                              giving: giving,
                              savings: savings,
                              debt: debt,
                              transfer: transfer,
                              transportation: transportation,
                              userId: Int(userId))
  }
  @discardableResult convenience init(id: Int16,
                                      food: Double?,
                                      housing: Double?,
                                      personal: Double?,
                                      income: Double?,
                                      giving: Double?,
                                      savings: Double?,
                                      debt: Double?,
                                      transfer: Double?,
                                      transportation: Double?,
                                      userId: Int16,
                                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
    self.init(context:context)
    self.id             = id
    self.food           = food ?? 0.0
    self.housing        = housing ?? 0.0
    self.personal       = personal ?? 0.0
    self.income         = income ?? 0.0
    self.giving         = giving ?? 0.0
    self.savings        = savings ?? 0.0
    self.debt           = debt ?? 0.0
    self.transfer       = transfer ?? 0.0
    self.transportation = transportation ?? 0.0
    self.userId         = userId
  }
  
  @discardableResult convenience init?(goalRepresentation: GoalRepresentation,
                                       context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
    
    self.init(id:Int16(goalRepresentation.id ?? 0) ,
              food:goalRepresentation.food,
              housing:goalRepresentation.housing,
              personal:goalRepresentation.personal,
              income:goalRepresentation.income,
              giving:goalRepresentation.giving,
              savings:goalRepresentation.savings,
              debt:goalRepresentation.debt,
              transfer:goalRepresentation.transfer,
              transportation:goalRepresentation.transportation,
              userId:Int16(goalRepresentation.userId ?? 0 )
    )
  }
}
