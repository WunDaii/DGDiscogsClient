//
//  DGDiscogsHelperTests.swift
//  DGDiscogsHelperTests
//
//  Created by Daven Gomes on 11/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import XCTest
@testable import DGDiscogsHelper

class DGDiscogsHelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAuth() {
    }
    
    func testAuthUser() {
        
        let asyncExpectation = expectation(description: "testAuthUser")
        
        RequestHelper.sharedInstance.request(url: "oauth/identity", method: .get, parameters: nil,  completion: { (result) in
            
            asyncExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            XCTAssertNotNil("Test")
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        print("test Example")
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        
        BaseTestFile().run { () -> Void? in
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            XCTAssertNotNil("Test")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            print("test measure")
        }
    }
}
