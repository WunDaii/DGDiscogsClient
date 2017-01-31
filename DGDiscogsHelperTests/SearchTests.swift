//
//  SearchTests.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 19/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import XCTest
@testable import DGDiscogsHelper

class SearchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testQuerySearch() {
        
        var params = DGDiscogsSearch.Parameters()
        params.releaseTitle = "RL Grime"
        
        let search = DGDiscogsSearch(parameters: params),
            pagination = DGDiscogsUtils.Pagination(page: 1, perPage: 50)

        
        let asyncExpectation = expectation(description: "Search")
        
        search.search(for: pagination, completion: { (result) in
            
            switch result {
            case .success(let pagination, let results):
                // Process result
                
                guard let results = results else { return }
                
                for result in results {
                    if let result = result as? DGDiscogsRelease {
                        print("-- \(result.title)")
                    } else if let result = result as? DGDiscogsArtist {
                        print("-- artist : \(result.name)")
                    }
                }
                
                break
            case .failure(let error):
                // Handle error
                break
            }
            
            asyncExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            XCTAssertNotNil(params.releaseTitle, "Search params releaseTitle should not be nil")
        }
    }
    
    func testParamtersDictionary() {
        
        var params = DGDiscogsSearch.Parameters()
        params.query = "myQuery"
        params.releaseTitle = "myReleaseTitle"
        
        let expected : [String : String] = ["query" : "myQuery",
                                            "release_title" : "myReleaseTitle"]
        
        XCTAssertEqual(params.dictionary["query"] as? String, expected["query"])
        XCTAssertEqual(params.dictionary["release_title"] as? String, expected["myReleaseTitle"])
    }
}
