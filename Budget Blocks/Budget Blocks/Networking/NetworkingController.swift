//
//  NetworkingController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/27/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import SwiftyJSON
import KeychainSwift
import CoreData


enum NetworkError:String, Error {
  case badURL      = "Bad URL"
  case badResponse = "Bad Response"
  case invalidData = "Invalid Data"
}

struct BodyForPlaidPost: Encodable {
  let publicToken: String
}

enum HTTPMethod: String {
  case get    = "GET"
  case post   = "POST"
  case put    = "PUT"
  case delete = "DELETE"
}

enum HTTPHeader: String {
  case contentType = "Content-Type"
  case auth        = "Authorization"
}

class NetworkingController {
  
  //    https://sandbox.plaid.com/transactions/get
  static let shared = NetworkingController()
  static var userID : Int = 0
  static let oktaDomain = URL(string: "https://dev-985629.okta.com/oauth2/default")!
  private let baseURL = URL(string: "https://lambda-budget-blocks.herokuapp.com/")!
  private let newBaseURL = URL(string: "https://budget-blocks-production-new.herokuapp.com")!
  private let plaidBaseURL = URL(string: "https://sandbox.plaid.com/")!
  
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()

  static var dataArrayTransactions : DataScienceTransactionRepresentations?
  var census: CensusData?
  
  
  static let dateFormatter: DateFormatter = {
    let fm = DateFormatter()
    fm.calendar = .current
    fm.locale = Locale(identifier: "en_US_POSIX")
    fm.dateFormat = "yyyy-MM-dd"
    return fm
  }()
  
  // MARK: Account

  func registerUserToDatabase(user:UserRepresentation,accessToken: String, completion: @escaping (UserRep?,Error?) -> Void) {
    let registerURL = newBaseURL.appendingPathComponent("api")
      .appendingPathComponent("users")
    
    var request = URLRequest(url: registerURL)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    do {
      let jsonData = try self.jsonEncoder.encode(user)
      request.httpBody = jsonData
    } catch {
      print(error.localizedDescription)
      completion(nil,error)
      return
    }
    print(registerURL)
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      
      if let error = error {
        completion(nil,error)
        return
      }
      guard let data = data else { return }
      print(String(data: data, encoding: .utf8)!)
      if let response = response as? HTTPURLResponse, response.statusCode != 200 {
        print(response)
        completion( nil, NSError(domain: "", code: response.statusCode, userInfo: nil))
      }
      do {
        let user = try self.jsonDecoder.decode(UserRep.self, from: data)
        print("HERE IS ID \(user.data.id!)")
        completion(user,nil)
      } catch {
        print(error.localizedDescription)
      }
      
    }.resume()
  }
  
  func sendTransactionsToDataScience(_ transaction: OnlineTransactions, completion: @escaping (DataScienceTransactionRepresentations, Error?) -> Void) {
    let endpoint = URL(string: "https://api.budgetblocks.org/transaction")!
    var request = URLRequest(url: endpoint)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    jsonEncoder.dateEncodingStrategy = .formatted(NetworkingController.dateFormatter)
    jsonEncoder.dataEncodingStrategy = .base64
    
    
    guard let dataToSend = try? jsonEncoder.encode(transaction) else { return }
    
    URLSession.shared.uploadTask(with: request, from: dataToSend) { (data, response, error) in
      if let err = error {
        print(err.localizedDescription)
      }
      
      print(response!)
      print("DATA COMING BACK FROM DATA SCIENCE \(String(data: data!,encoding: .utf8))")
      guard let data = data else { return }
      do {
        let dataScienceDataArray = try self.jsonDecoder.decode(DataScienceTransactionRepresentations.self, from: data)
        NetworkingController.dataArrayTransactions = dataScienceDataArray
        print(dataScienceDataArray.transactions)
        completion(dataScienceDataArray,nil)
        // CoreData
        for transaction in dataScienceDataArray.transactions {
          guard let _ = self.fetchTransaction(transaction.transactionID) else {
            let _ = DataScienceTransaction(dataScienceTransactionRepresentation: transaction, context: CoreDataStack.shared.mainContext)
            continue
          }
        }
      } catch {
        print(error.localizedDescription)
      }
    }.resume()
  }
  
  //Helper function to not get duplicate core data fetching
  private func fetchTransaction(_ transactionID: String) -> DataScienceTransaction? {
    let moc = CoreDataStack.shared.mainContext
    let dataScienceTransactionFetch = NSFetchRequest<DataScienceTransaction>(entityName: String(describing: DataScienceTransaction.self))
    dataScienceTransactionFetch.predicate = NSPredicate(format: "transactionID == %@",transactionID)
    do {
      let fetchedTransactions = try moc.fetch(dataScienceTransactionFetch)
      return fetchedTransactions.first
    } catch {
      fatalError("Failed to fetch employees: \(error)")
    }
  }
  
  func sendCensusToDataScience(location:[String],userId: Int,completion: @escaping (Error?) -> Void) {
    let endpoint = URL(string: "https://api.budgetblocks.org/census")!
    var request = URLRequest(url: endpoint)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
      let census = CensusToPost(location: location, userId: userId)
      let jsonCensusData = try jsonEncoder.encode(census)
      request.httpBody = jsonCensusData
    } catch let err as NSError {
      print(err.localizedDescription)
    }
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print(error.localizedDescription)
      }
      guard let data = data else { return }
      print(String(data: data, encoding: .utf8) as Any)
      print(response!)
      do {
        let jsonCensus = try self.jsonDecoder.decode(CensusDataRepresentation.self, from: data)
        self.census = CensusData(censusRepresentation: jsonCensus, context: CoreDataStack.shared.mainContext)
        
      } catch {
        print(error.localizedDescription)
      }
    }.resume()
  }
  
  func getTransactionsFromPlaid(of client: Client,completion: @escaping (Result<OnlineTransactions,NetworkError>) -> Void) {
    let endpoint = plaidBaseURL
      .appendingPathComponent("transactions")
      .appendingPathComponent("get")
    print(endpoint)
    var request = URLRequest(url: endpoint)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
      jsonEncoder.dateEncodingStrategy = .formatted(NetworkingController.dateFormatter)
      jsonEncoder.dataEncodingStrategy = .base64
      let jsonClientData = try jsonEncoder.encode(client)
      request.httpBody = jsonClientData
    } catch let err as NSError {
      print(err.localizedDescription)
    }
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let err = error {
        print(err.localizedDescription)
      }
      guard let response = response else { return }
      print("RESPONSE \(response)")
      guard let data = data else { return }
      
      do {
        self.jsonDecoder.dataDecodingStrategy = .deferredToData
        self.jsonDecoder.dateDecodingStrategy = .formatted(NetworkingController.dateFormatter)
        
        let transactions = try self.jsonDecoder.decode(OnlineTransactions.self, from: data)
        
        completion(.success(transactions))
        
      } catch {
        print("Error DECODING \(error.localizedDescription)")
      }
    }.resume()
  }
  
  func getAccessTokenFromUserId(userID: Int,completion: @escaping (Result<BankInfos,NetworkError>) -> Void ) {
    let endpoint = newBaseURL
      .appendingPathComponent("plaid")
      .appendingPathComponent("accessToken")
      .appendingPathComponent(String(userID))
    print(endpoint)
    var request = URLRequest(url: endpoint)
    request.httpMethod = HTTPMethod.get.rawValue
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let err = error {
        completion(.failure(.badURL))
        print(err.localizedDescription)
      }
      print(response!)
      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        completion(.failure(.badResponse))
        return
      }
      guard let data = data else {
        completion(.failure(.invalidData))
        return
      }
      do {
        let jsonBankInfo = try self.jsonDecoder.decode(BankInfos.self, from: data)
        completion(.success(jsonBankInfo))
      } catch let err {
        print(err.localizedDescription)
      }
    }.resume()
  }
  
  func sendPlaidPublicTokenToServerToGetAccessToken(publicToken: String,userID: Int, completion: @escaping (Error?) -> Void) {
    let endpoint = newBaseURL
      .appendingPathComponent("plaid")
      .appendingPathComponent("token_exchange")
      .appendingPathComponent(String(userID))
    
    print(endpoint)
    var request = URLRequest(url: endpoint)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = BodyForPlaidPost(publicToken: publicToken)
    
    guard let uploadData = try? jsonEncoder.encode(body) else { return }
    
    let task = URLSession.shared.uploadTask(with: request, from:uploadData) { (data, response, error) in
      if let error = error {
        print ("error: \(error)")
        return
      }
      
      if let response = response as? HTTPURLResponse,
        (200...299).contains(response.statusCode)  {
        print(response.statusCode)
      }
      let json = try? JSON(data: data!)
      print(json as Any)
      if let mimeType = response?.mimeType,
        mimeType == "application/json",
        let data = data,
        let dataString = String(data: data, encoding: .utf8) {
        print ("got data: \(dataString)")
      }
    }
    task.resume()
  }
  
  func registerNewUser(user: RegisteringUser,completion: @escaping (Result<Data,Error>) -> Void) {
    let endpoint = URL(string: "https://dev-985629.okta.com/api/v1/users?activate=true")!
    var request = URLRequest(url: endpoint)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let oktaAPIKey = ProcessInfo.processInfo.environment["OKTA_SIGNUP_API_KEY"]!
    request.setValue(oktaAPIKey, forHTTPHeaderField: "Authorization")
    do {
      let newUserData = try self.jsonEncoder.encode(user)
      request.httpBody = newUserData
    } catch let error   {
      print(error.localizedDescription)
      completion(.failure(error))
      return
    }
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print(error.localizedDescription)
        
        completion(.failure(error))
        return
      }
      if let response = response as? HTTPURLResponse,
        response.statusCode != 200 {
        print(response)
        completion(.failure(NetworkError.badURL))
      }
      if let data = data {
        completion(.success(data))
      }
    }.resume()
  }
  
  func setBudgetGoal(goal: GoalRepresentation,completion: @escaping (Result<GoalRepresentation,Error>) -> Void) {
    var endpoint = URL(string: "https://budget-blocks-production-new.herokuapp.com/api/goals")!
    endpoint.appendPathComponent(String(UserController.userID!))
    var request = URLRequest(url: endpoint)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
      let goalDataToPut = try jsonEncoder.encode(goal)
      request.httpBody = goalDataToPut
    } catch {
      print(error.localizedDescription)
    }
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print(error.localizedDescription)
        completion(.failure(NetworkError.badURL))
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print("Error with the response, unexpected status code: \(response)")
          completion(.failure(NetworkError.badResponse))
          return
      }
      guard let data = data else { return }
      do {
        let newGoal = try self.jsonDecoder.decode(GoalRepresentation.self, from: data)
        UserController.shared.currentUserGoal = Goal(goalRepresentation: newGoal)!
      } catch {
      }
    }.resume()
  }
}

