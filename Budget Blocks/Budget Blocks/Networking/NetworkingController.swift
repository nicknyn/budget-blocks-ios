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
  case badURL = "Bad URL"
  case badResponse = "Bad Response"
  case invalidData = "Invalid Data"
}

struct BodyForPlaidPost: Encodable {
  let publicToken: String
}

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

enum HTTPHeader: String {
  case contentType = "Content-Type"
  case auth = "Authorization"
}

class NetworkingController {
  
  static let shared = NetworkingController()
  static var userID : Int = 0
  static let oktaDomain = URL(string: "https://dev-985629.okta.com/oauth2/default")!
  private let baseURL = URL(string: "https://lambda-budget-blocks.herokuapp.com/")!
  private let newBaseURL = URL(string: "https://budget-blocks-production-new.herokuapp.com")!
  //    https://sandbox.plaid.com/transactions/get
  private let plaidBaseURL = URL(string: "https://sandbox.plaid.com/")!
  private let emailKey = "email"
  private let passwordKey = "password"
  private let keychain = KeychainSwift()
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()
  var census: CensusData?
  var bearer: Bearer?
  
  static let dateFormatter: DateFormatter = {
    let fm = DateFormatter()
    fm.calendar = .current
    fm.locale = Locale(identifier: "en_US_POSIX")
    fm.dateFormat = "yyyy-MM-dd"
    return fm
  }()
  
  
  var linkedAccount: Bool {
    return bearer?.linkedAccount ?? false
  }
  var manualAccount: Bool {
    return bearer?.manualAccount ?? false
  }
  var accountSetUp: Bool {
    return linkedAccount || manualAccount
  }
  
  enum URLPathComponent: Equatable {
    case auth(register: Bool)
    case categories
    case tokenExchange
    case manualOnboard
    case transactions(transactionID: Int32?)
    case manualCategories(categoryID: Int32?)
  }
  
  // MARK: Account
  
  func loginWithKeychain(completion: @escaping (Bool) -> Void) {
    guard let email = keychain.get(emailKey),
      let password = keychain.get(passwordKey) else {
        return completion(false)
    }
    
    print("Logging in...")
    login(email: email, password: password) { token, error in
      if let error = error {
        NSLog("\(error)")
        self.logout()
        return completion(false)
      }
      
      guard let token = token else {
        NSLog("No token returned from login.")
        self.logout()
        return completion(false)
      }
      
      print("Login successful! Session token: \(token)")
      completion(true)
    }
  }
  
  func login(email: String, password: String, completion: @escaping (String?, Error?) -> Void) {
    let loginJSON: JSON = ["email": email, "password": password]
    
    guard let request = createRequest(urlComponents: .auth(register: false), httpMethod: .post, json: loginJSON) else { return completion(nil, nil) }
    
    URLSession.shared.dataTask(with: request) { data, _, error in
      guard let data = data else {
        NSLog("No data returned from login request")
        return completion(nil, error)
      }
      completion(self.jsonData(data: data, email: email, password: password), nil)
    }.resume()
  }
  
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
  
  func jsonData(data: Data, email: String,password: String) -> String {
    let _: JSON = ["email": email, "password": password]
    let myToken = ""
    
    do {
      let responseJSON = try JSON(data: data)
      if  let token = responseJSON["token"].string,
        let userID = responseJSON["id"].int,
        let linked = responseJSON["LinkedAccount"].bool,
        let manual = responseJSON["ManualOnly"].bool {
        self.bearer = Bearer(token: token, userID: userID, linkedAccount: linked, manualAccount: manual)
        self.keychain.set(email, forKey: self.emailKey)
        self.keychain.set(password, forKey: self.passwordKey)
      }
      guard let myToken = responseJSON["token"].string else { fatalError() }
      return myToken
    } catch {
      //TODO: add action alert to tell user the error happened
      print("logging error: \(error.localizedDescription)")
    }
    return myToken
  }
  
  func register(email: String, password: String, firstName: String, lastName: String, completion: @escaping (String?, Error?) -> Void) {
    let registerJSON: JSON = ["email": email,
                              "password": password,
                              "first_name": firstName,
                              "last_name": lastName]
    
    guard let request = createRequest(urlComponents: .auth(register: true), httpMethod: .post, json: registerJSON) else { return completion(nil, nil) }
    
    URLSession.shared.dataTask(with: request) { data, _, error in
      guard let data = data else {
        NSLog("No data returned from register request")
        return completion(nil, error)
      }
      
      do {
        let responseJSON = try JSON(data: data)
        if let email = responseJSON["message"].string {
          completion(email, nil)
        } else {
          completion(responseJSON["error"].string, nil)
        }
      } catch {
        completion(nil, error)
      }
    }.resume()
  }
  
  func logout() {
    bearer = nil
    keychain.clear()
  }
  static var transactions : DataScienceTransactionRepresentations?
  
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
  
  func fetchTransaction(_ transactionID: String) -> DataScienceTransaction? {
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
      print(String(data: data, encoding: .utf8))
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
      print(json)
      if let mimeType = response?.mimeType,
        mimeType == "application/json",
        let data = data,
        let dataString = String(data: data, encoding: .utf8) {
        print ("got data: \(dataString)")
      }
    }
    task.resume()
  }
  
  func tokenExchange(publicToken: String, completion: @escaping (Error?) -> Void) {
    guard let bearer = bearer else { return completion(nil) }
    let tokenJSON: JSON = ["publicToken": publicToken, "userid": bearer.userID]
    
    guard let request = createRequest(urlComponents: .tokenExchange, httpMethod: .post, json: tokenJSON) else { return completion(nil) }
    
    URLSession.shared.dataTask(with: request) { data, _, error in
      guard let data = data else {
        NSLog("No data returned from register request")
        return completion(error)
      }
      
      do {
        let responseJSON = try JSON(data: data)
        if responseJSON["ItemCreated"].int != nil {
          print("Access token inserted!")
          self.setLinked()
        } else {
          if let response = responseJSON.rawString() {
            NSLog("Unexpected response returned: \(response)")
          } else {
            NSLog("Unexpected response returned and can't be decoded.")
          }
        }
        completion(nil)
      } catch {
        completion(error)
      }
    }.resume()
  }
  
  func manualOnboard(completion: @escaping (Error?) -> Void) {
    guard let request = createRequest(urlComponents: .manualOnboard, httpMethod: .get) else { return completion(nil) }
    
    URLSession.shared.dataTask(with: request) { _, _, error in
      if error == nil {
        self.setManual()
      }
      completion(error)
    }.resume()
  }
  
  // MARK: -Categories and transactions-
  
  func fetchTransactionsFromServer(completion: @escaping (JSON?, Error?) -> Void) {
    guard let request = createRequest(urlComponents: .transactions(transactionID: nil), httpMethod: .get) else { return completion(nil,nil) }
    completeReturnedJSON(request: request, requestName: "transactions", completion: completion)
  }
  
  func fetchCategoriesFromServer(completion: @escaping (JSON?, Error?) -> Void) {
    guard let request = createRequest(urlComponents: .categories, httpMethod: .get) else { return completion(nil, nil) }
    completeReturnedJSON(request: request, requestName: "categories", completion: completion)
  }
  
  func setCategoryBudget(categoryID: Int32, budget: Int64, completion: @escaping (JSON?, Error?) -> Void) {
    let budgetFloat = Float(budget) / 100
    let budgetJSON: JSON = ["categoryid": categoryID, "budget": budgetFloat]
    
    guard let request = createRequest(urlComponents: .categories, httpMethod: .put, json: budgetJSON) else { return completion(nil, nil) }
    completeReturnedJSON(request: request, requestName: "set category", completion: completion)
  }
  
  func setLinked() {
    if !accountSetUp {
      bearer?.linkedAccount = true
    }
  }
  
  func setManual() {
    if !accountSetUp {
      bearer?.manualAccount = true
    }
  }
  
  // MARK:- Manual-
  
  func createTransaction(amount: Int64, date: Date, category: TransactionCategory, name: String?, completion: @escaping (JSON?, Error?) -> Void) {
    guard category.categoryID != 0 else { return completion(nil, nil) }
    
    let amountFloat = Float(amount) / 100
    
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [
      .withYear,
      .withMonth,
      .withDay,
      .withDashSeparatorInDate
    ]
    let dateString = dateFormatter.string(from: date)
    
    var transactionJSON: JSON = ["amount": amountFloat,
                                 "payment_date": dateString,
                                 "category_id": category.categoryID]
    if let name = name {
      transactionJSON["name"].stringValue = name
    }
    
    guard let request = createRequest(urlComponents: .transactions(transactionID: nil), httpMethod: .post, json: transactionJSON) else { return completion(nil, nil) }
    completeReturnedJSON(request: request, requestName: "add transaction", completion: completion)
  }
  
  func deleteTransaction(transactionID: Int32, completion: @escaping (JSON?, Error?) -> Void) {
    guard let request = createRequest(urlComponents: .transactions(transactionID: transactionID), httpMethod: .delete) else { return completion(nil, nil) }
    completeReturnedJSON(request: request, requestName: "delete transaction", completion: completion)
  }
  
  func createCategory(named name: String, completion: @escaping (JSON?, Error?) -> Void) {
    let categoryJSON: JSON = ["name": name]
    
    guard let request = createRequest(urlComponents: .manualCategories(categoryID: nil), httpMethod: .post, json: categoryJSON) else { return completion(nil, nil) }
    completeReturnedJSON(request: request, requestName: "create category", completion: completion)
  }
  
  func deleteCategory(categoryID: Int32, completion: @escaping (JSON?, Error?) -> Void) {
    guard let request = createRequest(urlComponents: .manualCategories(categoryID: categoryID), httpMethod: .delete) else { return completion(nil, nil) }
    completeReturnedJSON(request: request, requestName: "delete category", completion: completion)
  }
  
  // MARK: Private
  
  private func completeReturnedJSON(request: URLRequest, requestName: String, completion: @escaping (JSON?, Error?) -> Void) {
    URLSession.shared.dataTask(with: request) { data, _, error in
      guard let data = data else {
        NSLog("No data returned from \(requestName) request.")
        return completion(nil, error)
      }
      
      do {
        let responseJSON = try JSON(data: data)
        completion(responseJSON, nil)
      } catch {
        completion(nil, error)
      }
    }.resume()
  }
  
  private func createRequest(urlComponents: URLPathComponent, httpMethod: HTTPMethod, json: JSON? = nil) -> URLRequest? {
    var url: URL
    
    let userID = bearer?.userID ?? 0
    switch urlComponents {
      case .auth(let register):
        url = baseURL
          .appendingPathComponent("api")
          .appendingPathComponent("auth")
          .appendingPathComponent(register ? "register" : "login")
      case .categories:
        url = baseURL
          .appendingPathComponent("api")
          .appendingPathComponent("users")
          .appendingPathComponent("categories")
          .appendingPathComponent("\(userID)")
      case .tokenExchange:
        url = baseURL
          .appendingPathComponent("plaid")
          .appendingPathComponent("token_exchange")
      case .manualOnboard:
        url = baseURL
          .appendingPathComponent("manual")
          .appendingPathComponent("onboard")
          .appendingPathComponent("\(userID)")
      case .transactions(let transactionID):
        url = baseURL
          .appendingPathComponent(manualAccount ? "manual" : "plaid")
          .appendingPathComponent("transaction\(manualAccount ? "" : "s")")
          .appendingPathComponent("\(userID)")
        if let transactionID = transactionID {
          url = url.appendingPathComponent("\(transactionID)")
      }
      case .manualCategories(let categoryID):
        url = baseURL
          .appendingPathComponent("manual")
          .appendingPathComponent("categories")
          .appendingPathComponent("\(userID)")
        if let categoryID = categoryID {
          url = url.appendingPathComponent("\(categoryID)")
      }
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.rawValue
    
    switch urlComponents {
      case .auth(_):
        break
      default:
        guard let bearer = bearer else { return nil }
        request.addValue(bearer.token, forHTTPHeaderField: HTTPHeader.auth.rawValue)
    }
    
    if let json = json {
      do {
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        request.httpBody = try json.rawData()
      } catch {
        NSLog("Error encoding json: \(error)")
        return nil
      }
    }
    return request
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

