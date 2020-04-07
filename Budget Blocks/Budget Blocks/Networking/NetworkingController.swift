//
//  NetworkingController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/27/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import SwiftyJSON
import KeychainSwift

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
    private let baseURL = URL(string: "https://lambda-budget-blocks.herokuapp.com/")!
    
    private let emailKey = "email"
    private let passwordKey = "password"
    private let keychain = KeychainSwift()
    
    var bearer: Bearer?
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
    
    // MARK: Categories and transactions
    
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
    
    // MARK: Manual
    
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
}
