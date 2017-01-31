//
//  ArtistTests.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 13/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import XCTest
@testable import DGDiscogsHelper



class ArtistTests: XCTestCase {
    
    var artist = DGDiscogsArtist(json: JSON(["id":2839269])),
    pagination = DGDiscogsUtils.Pagination(page: 1, perPage: 20)
    var infoJSON,
    releasesJSON: JSON!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: type(of: self))
        print(bundle.bundlePath)
        guard
            let infoPath = bundle.path(forResource: "info", ofType: "json", inDirectory: "JSON/Entities/Database/artist"),
            let releasesPath = bundle.path(forResource: "releases", ofType: "json", inDirectory: "JSON/Entities/Database/artist")
            else {
                fatalError("Cannot find resource")
                 }

        do {
            let infoData = try Data(contentsOf: URL(fileURLWithPath: infoPath), options: .alwaysMapped),
            releasesData = try Data(contentsOf: URL(fileURLWithPath: releasesPath), options: .alwaysMapped)

            self.infoJSON = JSON(data: infoData)
            self.releasesJSON = JSON(data: releasesData)
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let url = "users/wundaii/wants",
        asyncExpectation = expectation(description: "Testing Expectation > \(url)")
        
        RequestHelper.sharedInstance.request(url: url, method: .get, parameters: nil,  completion: { (_, json) in
            
            let wantlist = DGDiscogsUser.Wantlist(json: json)
            
            for want in wantlist.wants {
                print("-- \(want.dateAdded)")
            }
            
            
                asyncExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 10) { (error) in
            
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetReleases() {
        
        let asyncExpectation = expectation(description: "Artist get releases")
        
        artist.getReleases(for: pagination, completion: { (result) in
            asyncExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            XCTAssertNotNil(self.artist.releases, "Artist releases should not be nil")
            XCTAssert((self.artist.releases?.count)! > 0)
        }
    }
    
    func testGetInfo() {
        
        let asyncExpectation = expectation(description: "Artist get info")
        
        artist.getInfo(completion: { (result) in
            
            switch (result) {
            case .success(item: let item):
                if let artist = item as? DGDiscogsArtist {
                    self.artist = artist
                }
                break;
            case .failure(error: let error):
                break;
            }
            
            asyncExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            XCTAssertEqual(self.artist.name, "RL Grime")
        }
    }
}
