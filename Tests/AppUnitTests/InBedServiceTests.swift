//
//  InBedServiceTest.swift
//  VaporApp
//
//  Created by Eric on 16/12/2016.
//
//

import XCTest
import RxSwift


class InBedServiceTest: XCTestCase
{
    func testRetrieveIsInBed()
    {
        let expectation = self.expectation(description: "Handler called")
        let inbedService = InBedService()
        _  = inbedService.isInBed.subscribe { (event:Event<Bool>) in
            print(event)
            XCTAssertNil(event.error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { (error:Error?) in print(error as Any)}
    }

    
 }

