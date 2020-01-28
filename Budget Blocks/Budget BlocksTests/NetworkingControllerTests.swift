//
//  NetworkingControllerTests.swift
//  Budget BlocksTests
//
//  Created by Isaac Lyons on 1/27/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import XCTest
@testable import Budget_Blocks

class NetworkingControllerTests: XCTestCase {

    func testLogin() {
        let networkingController = NetworkingController()
        let expectation = self.expectation(description: "Login")
        
        networkingController.login(email: "email@example.com", password: "password") { token, error in
            if let error = error {
                XCTFail("\(error)")
            }
            
            XCTAssertNotNil(token)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 100, handler: nil)
    }

}
