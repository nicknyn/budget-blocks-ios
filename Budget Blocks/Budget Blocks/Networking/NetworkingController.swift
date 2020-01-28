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
    private let baseURL = URL(string: "https://lambda-budget-blocks.herokuapp.com/api/")!
    
    func login(email: String, password: String, completion: @escaping (String?, Error?) -> Void) {
        let loginJSON = JSON(dictionaryLiteral: ("email", email), ("password", password))
        
        let url = baseURL.appendingPathComponent("auth")
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
        
        let url = baseURL.appendingPathComponent("auth")
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
                    if let email = responseJSON["email"].string {
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
}
