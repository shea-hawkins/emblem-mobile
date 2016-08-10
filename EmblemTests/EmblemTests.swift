//
//  EmblemTests.swift
//  EmblemTests
//
//  Created by Dane Jordan on 8/3/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import XCTest

@testable import Emblem


class EmblemTests: XCTestCase {
    var mapvc:MapViewController!
    
//    override func spec() {
//        describe("Test2") {
//            it("should test stuff")
//            expect(1 + 1).to(equal(2))
//        }
//    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        mapvc = storyboard.instantiateInitialViewController() as! MapViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTest() {
        XCTAssertTrue(true)
    }
    
    func testPost() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        expect(1 + 1).to(equal(2))
        
        if let DEV_SERVER = NSProcessInfo.processInfo().environment["DEV_SERVER"] as String? {
            mapvc.post(["lat": "1", "long": "2"], url: NSURL(string: DEV_SERVER)!, postCompleted: { (succeeded, msg) in
                XCTAssertTrue(true)
                var json:NSData = NSData()
                do {
                    json = try NSJSONSerialization.dataWithJSONObject(msg, options: [])
                } catch {
                    print(error)
                }
                print(json)
//                for (_, SubJson):(String, AnyObject) in json {
//                    XCTAssert(subJSON["lat"] as String == "1", "Latitude expected to be 1")
//                    XCTAssert(subJSON["long"] as String == "2", "Longitude expected to be 2")
//                }

            })
            
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
