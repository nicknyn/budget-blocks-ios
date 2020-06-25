//
//  AccessToken.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/1/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct BankInfo : Codable {
  let accessToken : String

  enum CodingKeys: String,CodingKey {
    case accessToken = "access_token"
  }
}

struct BankInfos: Codable {
  let data : [BankInfo]
}
