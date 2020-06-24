//
//  User.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 5/28/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct UserRep : Decodable {
  let data : UserRepresentation
}

struct UserRepresentation: Codable {
  var id: Int?
  var name: String
  var email: String
  
  enum CodingKeys: String,CodingKey {
    case id = "id"
    case name
    case email
  }
}
