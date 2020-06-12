//
//  Transaction.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/1/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct Client: Codable {
    let clientID : String
    let secret: String
    let accessToken: String
    let startDate: String
    let endDate : String
    
    enum CodingKeys: String,CodingKey {
        case clientID    = "client_id"
        case secret      = "secret"
        case accessToken = "access_token"
        case startDate   = "start_date"
        case endDate     = "end_date"
    } // Ready for PLAID 
}
