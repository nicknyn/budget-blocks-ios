//
//  GoalRepresentation.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/23/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct GoalRepresentation: Codable {
  let id             : Int?
  let food           : Double?
  let housing        : Double?
  let personal       : Double?
  let income         : Double?
  let giving         : Double?
  let savings        : Double?
  let debt           : Double?
  let transfer       : Double?
  let transportation : Double?
  let userId         : Int?
  
  enum CodingKeys: String,CodingKey {
    case id
    case food
    case housing
    case personal
    case income
    case giving
    case savings
    case debt
    case transfer
    case transportation
    case userId = "user_id"
  }
}
