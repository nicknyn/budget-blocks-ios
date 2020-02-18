//
//  NetworkingController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/27/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    private var authURL: URL {
        baseURL.appendingPathComponent("api")
            .appendingPathComponent("auth")
    }
    private var categoriesURL: URL? {
        guard let bearer = bearer else { return nil }
        return baseURL.appendingPathComponent("api")
            .appendingPathComponent("users")
            .appendingPathComponent("categories")
            .appendingPathComponent("\(bearer.userID)")
    }
    
    private let bearerTokenKey = "bearerToken"
    private let userIDKey = "userIDKey"
    private let linkedAccountKey = "linkedAccount"
    private let userDefaults = UserDefaults.standard
    
    var bearer: Bearer?
    var linkedAccount: Bool {
        return bearer?.linkedAccount ?? false
    }
    
    init() {
        let userID = userDefaults.integer(forKey: userIDKey)
        let linkedAccount = userDefaults.bool(forKey: linkedAccountKey)
        if let token = userDefaults.string(forKey: bearerTokenKey),
            userID != 0 {
            bearer = Bearer(token: token, userID: userID, linkedAccount: linkedAccount)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (String?, Error?) -> Void) {
        let loginJSON = JSON(dictionaryLiteral: ("email", email), ("password", password))
        
        let url = authURL.appendingPathComponent("login")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        
        do {
            request.httpBody = try loginJSON.rawData()
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data else {
                    NSLog("No data returned from login request")
                    return completion(nil, error)
                }
                
                do {
                    let responseJSON = try JSON(data: data)
                    if let token = responseJSON["token"].string,
                        let userID = responseJSON["id"].int,
                        let linked = responseJSON["LinkedAccount"].bool {
                        self.bearer = Bearer(token: token, userID: userID, linkedAccount: linked)
                        self.userDefaults.set(token, forKey: self.bearerTokenKey)
                        self.userDefaults.set(userID, forKey: self.userIDKey)
                        self.userDefaults.set(linked, forKey: self.linkedAccountKey)
                    }
                    completion(responseJSON["token"].string, nil)
                } catch {
                    completion(nil, error)
                }
            }.resume()
        } catch {
            completion(nil, error)
        }
    }
    
    func register(email: String, password: String, completion: @escaping (String?, Error?) -> Void) {
        let registerJSON = JSON(dictionaryLiteral: ("email", email), ("password", password))
        
        let url = authURL.appendingPathComponent("register")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        
        do {
            request.httpBody = try registerJSON.rawData()
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
        } catch {
            completion(nil, error)
        }
    }
    
    func logout() {
        bearer = nil
        self.userDefaults.removeObject(forKey: bearerTokenKey)
        self.userDefaults.removeObject(forKey: userIDKey)
        self.userDefaults.removeObject(forKey: linkedAccountKey)
    }
    
    func tokenExchange(publicToken: String, completion: @escaping (Error?) -> Void) {
        guard let bearer = bearer else { return completion(nil) }
        let tokenJSON = JSON(dictionaryLiteral: ("publicToken", publicToken), ("userid", bearer.userID))
        
        let url = baseURL.appendingPathComponent("plaid")
            .appendingPathComponent("token_exchange")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        request.addValue(bearer.token, forHTTPHeaderField: HTTPHeader.auth.rawValue)
        
        do {
            request.httpBody = try tokenJSON.rawData()
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data else {
                    NSLog("No data returned from register request")
                    return completion(error)
                }
                
                do {
                    let responseJSON = try JSON(data: data)
                    if responseJSON["ItemCreated"].int != nil {
                        print("Access token inserted!")
                        self.bearer?.linkedAccount = true
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
        } catch {
            completion(error)
        }
    }
    
    func fetchTransactionsFromServer(completion: @escaping (JSON?, Error?) -> Void) {
        guard let bearer = bearer else { return completion(nil, nil) }
        
        let url = baseURL
            .appendingPathComponent("plaid")
            .appendingPathComponent("transactions")
            .appendingPathComponent("\(bearer.userID)")
        var request = URLRequest(url: url)
        request.addValue(bearer.token, forHTTPHeaderField: HTTPHeader.auth.rawValue)
        
        completeReturnedJSON(request: request, requestName: "transactions", completion: completion)
    }
    
    func fetchCategoriesFromServer(completion: @escaping (JSON?, Error?) -> Void) {
        guard let bearer = bearer,
            let url = categoriesURL else { return completion(nil, nil) }
        var request = URLRequest(url: url)
        request.addValue(bearer.token, forHTTPHeaderField: HTTPHeader.auth.rawValue)
        
        completeReturnedJSON(request: request, requestName: "categories", completion: completion)
    }
    
    func setCategoryBudget(categoryID: Int32, budget: Int64, completion: @escaping (JSON?, Error?) -> Void) {
        guard let bearer = bearer,
            let url = categoriesURL else { return completion(nil, nil) }
        let budgetFloat = Float(budget) / 100
        let budgetJSON = JSON(dictionaryLiteral: ("categoryid", categoryID), ("budget", budgetFloat))
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        request.addValue(bearer.token, forHTTPHeaderField: HTTPHeader.auth.rawValue)
        
        do {
            request.httpBody = try budgetJSON.rawData()
            completeReturnedJSON(request: request, requestName: "set category", completion: completion)
        } catch {
            completion(nil, error)
        }
    }
    
    func setLinked() {
        bearer?.linkedAccount = true
        self.userDefaults.set(true, forKey: self.linkedAccountKey)
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
}
