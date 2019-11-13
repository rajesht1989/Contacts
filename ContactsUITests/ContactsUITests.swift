//
//  ContactsUITests.swift
//  ContactsUITests
//
//  Created by Rajesh Thangaraj on 01/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import XCTest

class ContactsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = true
        app = XCUIApplication()
    }
    
    override func tearDown() {
    }
    
    func testNewContactValidation() {
        app.launch()
        app.navigationBars["Contacts"].buttons["Add"].tap()
        app.navigationBars["Contacts.ContactModificationView"].buttons["Save"].tap()
        
        let elementQ = app.alerts.containing(.staticText, identifier: "All fields are mandatory")
        XCTAssert(elementQ.element.exists, "Validation not working")
    }
    
    
    func testConactsFetched() {
        app.launch()
        app.navigationBars["Contacts"].buttons["Add"].tap()
        let tablesQuery = app.tables
        var textField = tablesQuery.cells.containing(.staticText, identifier:"First Name").children(matching: .textField).element
        textField.tap()
        textField.typeText("1111")
        
        textField = tablesQuery.cells.containing(.staticText, identifier:"Last Name").children(matching: .textField).element
        textField.tap()
        textField.typeText("aaa")
        
        textField = tablesQuery.cells.containing(.staticText, identifier:"Mobile").children(matching: .textField).element
        textField.tap()
        textField.typeText("+919999999999")
        
        textField = tablesQuery.cells.containing(.staticText, identifier:"Email").children(matching: .textField).element
        textField.tap()
        textField.typeText("r@e.in")
        app.navigationBars["Contacts.ContactModificationView"].buttons["Save"].tap()
        sleep(5)
    }
    
    func testMarkAsFavorite() {
        app.launch()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["1111 aaaaa"]/*[[".cells.staticTexts[\"1111 aaaaa\"]",".staticTexts[\"1111 aaaaa\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.buttons.containing(.staticText, identifier:"favorite").element.tap()
        sleep(1)
        
        let contactsButton = app.navigationBars["Contacts.ContactDetailView"].buttons["Contacts"]
        contactsButton.tap()
        sleep(5)
    }
    
    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
