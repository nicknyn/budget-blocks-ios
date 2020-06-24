//
//  OnlineTransaction.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/1/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct OnlineTransactions: Codable {
  let transactions : [OnlineTransaction]
  var userId : Int?
  
  enum CodingKeys: String, CodingKey {
    case transactions
    case userId = "user_id"
    
  }
}

struct OnlineTransaction: Codable {
  let accountId : String
  let accountOwner: String?
  let amount : Double
  let authorizedDate: String?
  let category : [String]
  let categoryId : String
  let date : String
  let isoCurrencyCode : String
  let location : Location
  let name: String
  let paymentChannel: String?
  let paymentMeta : PaymentMeta
  let pending: Bool?
  let pendingTransactionId: String?
  let transactionCode: String?
  let transactionId: String?
  let transactionType: String?
  let unofficialCurrencyCode: String?
  
  enum CodingKeys: String, CodingKey {
    case accountId              = "account_id"
    case accountOwner           = "account_owner"
    case amount                 = "amount"
    case authorizedDate         = "authorized_date"
    case category               = "category"
    case categoryId             = "category_id"
    case date                   = "date"
    case isoCurrencyCode        = "iso_currency_code"
    case location               = "location"
    case name                   = "name"
    case paymentChannel         = "payment_channel"
    case paymentMeta            = "payment_meta"
    case pending                = "pending"
    case pendingTransactionId   = "pending_transaction_id"
    case transactionCode        = "transaction_code"
    case transactionId          = "transaction_id"
    case transactionType        = "transaction_type"
    case unofficialCurrencyCode = "unofficial_currency_code"
  }
}

class Location:NSObject, Codable {
  let address: String?
  let city: String?
  let country: String?
  let latitude: String?
  let longitude: String?
  let postalCode: String?
  let region: String?
  let storeNumber: String?
  
  enum CodingKeys: String,CodingKey {
    case address       = "address"
    case city          = "city"
    case country       = "country"
    case latitude      = "lat"
    case longitude     = "lon"
    case postalCode    = "postal_code"
    case region        = "region"
    case storeNumber   = "store_number"
  }
}

struct PaymentMeta: Codable {
  let byOrderOf: String?
  let payee: String?
  let payer: String?
  let paymentMethod: String?
  let paymentProcessor: String?
  let ppdID: Int?
  let reason: String?
  let referenceNumber: Int?
  
  enum CodingKeys: String,CodingKey {
    case byOrderOf            = "by_order_of"
    case payee                = "payee"
    case payer                = "payer"
    case paymentMethod        = "payment_method"
    case paymentProcessor     = "payment_processor"
    case ppdID                = "ppd_id"
    case reason               = "reason"
    case referenceNumber      = "reference_number"
  }
}
