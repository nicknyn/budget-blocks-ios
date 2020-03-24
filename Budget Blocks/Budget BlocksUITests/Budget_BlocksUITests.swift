//
//  Budget_BlocksUITests.swift
//  Budget BlocksUITests
//
//  Created by Isaac Lyons on 1/24/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import XCTest
@testable import Budget_Blocks

class Budget_BlocksUITests: XCTestCase {
    
    private var app: XCUIApplication = { XCUIApplication() }()

    override func setUp() {
        continueAfterFailure = false

        app.launch()
        
        let signOutButton = app.buttons["Sign out"]
        if signOutButton.exists {
            signOutButton.tap()
        }
    }

    override func tearDown() {
    }

    //Both test now pass issue was with how simulator was set up
    // by disconnecting the keyboard of the mac the first responder will change
    
    func testLogin() {
        login()
        sleep(5)
        
        XCTAssertTrue(app.staticTexts["Dashboard"].exists)
    }
    
    func testViewTransactions() {
        login()
        sleep(5)
        
        app.staticTexts["View Transactions"].tap()
        XCTAssertTrue(app.staticTexts["Transactions"].exists)
    }
    
    private func login() {
        app.buttons["Sign In"].tap()
        
        app.textFields.firstMatch.tap()
        app.typeText("email@example.com")
        app.secureTextFields.firstMatch.tap()
        
        app.typeText("password")
        app.keyboards.buttons["Return"].tap()
        
        app.buttons.matching(identifier: "Sign In").element(boundBy: 1).tap()
    }
    
    
    private func loginTwo() {
        app.buttons["Sign In"].tap()
        
        app.textFields.firstMatch.tap()
        app.typeText("tylerc71197@gmail.com")
        app.secureTextFields.firstMatch.tap()
        
        app.typeText("123456")
        app.keyboards.buttons["Return"].tap()
        
        app.buttons.matching(identifier: "Sign In").element(boundBy: 1).tap()
    }
    
    
    private func logout() {
        app.buttons["Sign out"].tap()
    }
    
    func testSwitchingAccounts() {
        login()
        sleep(3)
        
        logout()
        
        loginTwo()
        sleep(3)
    }
    
    // wrote this test in the UI need to re-do it in the Networkingtest
//    func testBadInfo() {
//
//        let loggedin = true
//
//        app.buttons["Sign In"].tap()
//
//        app.textFields.firstMatch.tap()
//        app.typeText("badEmail@example.com")
//
//        app.secureTextFields.firstMatch.tap()
//        app.typeText("BadPassword")
//
//        app.keyboards.buttons["Return"].tap()
//        app.secureTextFields.firstMatch.tap()
//
//        app.buttons.matching(identifier: "Sign In").element(boundBy: 1).tap()
//        XCTAssertFalse(loggedin)
//
//    }
    
}
