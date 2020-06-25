//
//  Census.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct CensusToPost: Codable {
  let location: [String]
  let userId  : Int
  
  enum CodingKeys: String, CodingKey {
    case location = "location"
    case userId   = "user_id"
  }
}
