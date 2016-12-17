//
//  InBedServiceTest.swift
//  VaporApp
//
//  Created by Eric on 16/12/2016.
//
//

import XCTest

class InBedServiceTest: XCTestCase {
    
    var inBedService : InBedService?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetrieveIsInBed()
    {
        var timerCount = 1
        let expectation = self.expectation(description: "Handler called")
        self.inBedService = InBedService {(inBed:Bool?) in
            XCTAssertNotNil(inBed)
            if timerCount == 0 {expectation.fulfill()}
            timerCount -= timerCount
        }
        waitForExpectations(timeout: 130) { (error:Error?) in }
    }

}
