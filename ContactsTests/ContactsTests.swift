//
//  ContactsTests.swift
//  ContactsTests
//
//  Created by Rajesh Thangaraj on 01/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import XCTest
@testable import Contacts

class ContactsTests: XCTestCase {
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFetchContacts() {
        let exp = self.expectation(description: "testExpectation")
        Connection.contacts { (contacts, error) in
            XCTAssert(error == nil, "Contacts fetch failed")
            XCTAssert(contacts?.0 != nil, "Sorting failed")
            XCTAssert(contacts?.1 != nil || contacts?.2 == nil, "Grouping failed | Extraction failed")
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchContact() {
        let exp = self.expectation(description: "testExpectation")
        Connection.contacts { (contacts, error) in
            if let contact = contacts!.0.first {
                Connection.contactDetails(contact.id, completion: { (contact, error) in
                    XCTAssert(error == nil, "Contact fetch failed with error")
                    XCTAssert(contact != nil, "Contact fetch failed")
                    exp.fulfill()
                })
            } else {
                XCTFail("Empty contact list")
            }
        }
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testFetchImage() {
        let exp = self.expectation(description: "testExpectation")
        Connection.contacts { (contacts, error) in
            if let contact = contacts!.0.first {
                Connection.image(for: contact) { (imageData, error) in
                    XCTAssert(error == nil, "Image fetch failed with error")
                    XCTAssert(imageData?.0 != nil, "Image fetch failed")
                    XCTAssert(UIImage(data: imageData!.0) != nil, "Not received the imagedata")
                    exp.fulfill()
                }
            } else {
                XCTFail("Empty contact list")
            }
        }
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    
    func testPerformanceofFetchContacts() {
        self.measure {
            let exp = self.expectation(description: "testExpectation")
            Connection.contacts { (contacts, error) in exp.fulfill() }
            waitForExpectations(timeout: 15, handler: nil)
        }
    }
}
