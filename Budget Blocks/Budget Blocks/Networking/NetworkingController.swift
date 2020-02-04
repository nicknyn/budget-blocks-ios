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

class NetworkingController {
    private let baseURL = URL(string: "https://lambda-budget-blocks.herokuapp.com/")!
    private let bearerTokenKey = "bearerToken"
    private let userIDKey = "userIDKey"
    private let userDefaults = UserDefaults.standard
    
    var bearer: Bearer?
    
    init() {
        let userID = userDefaults.integer(forKey: userIDKey)
        if let token = userDefaults.string(forKey: bearerTokenKey),
            userID != 0 {
            bearer = Bearer(token: token, userID: userID)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (String?, Error?) -> Void) {
        let loginJSON = JSON(dictionaryLiteral: ("email", email), ("password", password))
        
        let url = baseURL.appendingPathComponent("api")
            .appendingPathComponent("auth")
            .appendingPathComponent("login")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try loginJSON.rawData()
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    return completion(nil, error)
                }
                
                guard let data = data else {
                    NSLog("No data returned from login request")
                    return completion(nil, nil)
                }
                
                do {
                    let responseJSON = try JSON(data: data)
                    if let token = responseJSON["token"].string,
                        let userID = responseJSON["id"].int {
                        self.bearer = Bearer(token: token, userID: userID)
                        self.userDefaults.set(token, forKey: self.bearerTokenKey)
                        self.userDefaults.set(userID, forKey: self.userIDKey)
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
        
        let url = baseURL.appendingPathComponent("api")
            .appendingPathComponent("auth")
            .appendingPathComponent("register")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try registerJSON.rawData()
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    return completion(nil, error)
                }
                
                guard let data = data else {
                    NSLog("No data returned from register request")
                    return completion(nil, nil)
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
    }
    
    func tokenExchange(publicToken: String, completion: @escaping (Error?) -> Void) {
        guard let bearer = bearer else { return }
        let tokenJSON = JSON(dictionaryLiteral: ("publicToken", publicToken), ("userid", bearer.userID))
        
        let url = baseURL.appendingPathComponent("plaid")
            .appendingPathComponent("token_exchange")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try tokenJSON.rawData()
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    return completion(error)
                }
                
                guard let data = data else {
                    NSLog("No data returned from register request")
                    return completion(nil)
                }
                
                do {
                    let responseJSON = try JSON(data: data)
                    if responseJSON["ItemCreated"].int != nil {
                        print("Access token inserted!")
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
        guard let bearer = bearer else { return }
        
        let url = baseURL
            .appendingPathComponent("plaid")
            .appendingPathComponent("transactions")
            .appendingPathComponent("\(bearer.userID)")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let data = data else {
                NSLog("No data returned from transactions request.")
                return completion(nil, nil)
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
