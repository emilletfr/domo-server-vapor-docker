//
//  SunriseSunsetServiceTests.swift
//  VaporApp
//
//  Created by Eric on 17/12/2016.
//
//

import XCTest
import RxSwift
import Foundation
//@testable import VaporApp

class SunriseSunsetServiceTests: XCTestCase {
    
    static let allTests = [("testRetrieveSunriseAndSunset", testRetrieveSunriseAndSunset)]

    func testRetrieveSunriseAndSunset()
    {
        let expectation = self.expectation(description: "Handler called")
        let sunriseSunsetService = SunriseSunsetService()
        let zipObservable = Observable.zip(sunriseSunsetService.sunriseTimeObserver, sunriseSunsetService.sunsetTimeObserver, resultSelector: { ($0, $1) })
        _  = zipObservable.subscribe { (event) in
            print(event)
            XCTAssertNil(event.error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { (error:Error?) in print(error as Any)}    }

}
