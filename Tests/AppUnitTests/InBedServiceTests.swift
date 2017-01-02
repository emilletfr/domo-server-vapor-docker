//
//  InBedServiceTest.swift
//  VaporApp
//
//  Created by Eric on 16/12/2016.
//
//

import XCTest

class InBedServiceTest: XCTestCase
{
    
    func testRetrieveIsInBed()
    {
        let expectation = self.expectation(description: "Handler called")
        let inbedService = InbedService<HttpToJsonClient>()
        inbedService.subscribe(isInBedDidChange:
            {
            XCTAssertNotNil(inbedService.isInBed)
            expectation.fulfill()
        }, isBusyDidChange: {})
        
        waitForExpectations(timeout: 10) { (error:Error?) in }
    }

    
    func testMultipleSubscribers()
    {
        var fulFillCount = 2
        let expectation = self.expectation(description: "Handler called")
        
        let inbedService1 = InbedServiceDefault.shared
        inbedService1.subscribe(isInBedDidChange:
            {
                XCTAssertNotNil(inbedService1.isInBed)
                fulFillCount -= 1; if fulFillCount == 0 {expectation.fulfill()
                }
        }, isBusyDidChange: {})
        
        let inbedService2 = InbedServiceDefault.shared
        inbedService2.subscribe(isInBedDidChange:
            {
                XCTAssertNotNil(inbedService2.isInBed)
                fulFillCount -= 1; if fulFillCount == 0 {expectation.fulfill()
                }
        }, isBusyDidChange: {})
        
     //   XCTAssertEqual(inbedService1, inbedService2)
        waitForExpectations(timeout: 10) { (error:Error?) in }
    }
}

