//
//  SunriseSunsetServiceTests.swift
//  VaporApp
//
//  Created by Eric on 17/12/2016.
//
//

import XCTest
import RxSwift

class SunriseSunsetServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRetrieveSunriseAndSunset()
    {
        let expectation = self.expectation(description: "Handler called")
        let sunriseSunsetService = SunriseSunsetService()
        
        let zipObservable = Observable.zip(sunriseSunsetService.sunriseTimeObserver, sunriseSunsetService.sunsetTimeObserver, resultSelector: {($0, $1)})

        _  = zipObservable.subscribe { (event) in
            print(event)
            XCTAssertNil(event.error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { (error:Error?) in print(error as Any)}    }

}
