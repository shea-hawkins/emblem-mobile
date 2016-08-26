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
    
//    override func spec() {
//        describe("Test2") {
//            it("should test stuff")
//            expect(1 + 1).to(equal(2))
//        }
//    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
