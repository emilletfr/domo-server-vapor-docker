//
//  IndoorTempServiceTests.swift
//  VaporApp
//
//  Created by Eric on 17/12/2016.
//
//

import XCTest
import RxSwift
//import RxTest


class IndoorTempServiceTests: XCTestCase
{
    func testRetrieveTemperatureAndHumidity()
    {
  //  obser
        let expectation = self.expectation(description: "Handler called")
        
        let indoorTempService = IndoorTempService<HttpToJsonClient, HourRepeatTimer>()
        
        _ = Observable.zip(indoorTempService.degres, indoorTempService.humidity)
        { degres, humidity in
            return (degres, humidity)
            }.retry(3).subscribe({ (event) in
                print(event)
                XCTAssertNil(event.error)
                expectation.fulfill()
            })
        
        self.waitForExpectations(timeout: 10) { (error:Error?) in print(error as Any)}
    }
}
