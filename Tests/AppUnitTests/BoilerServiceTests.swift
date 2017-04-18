//
//  BoilerServiceTests.swift
//  VaporApp
//
//  Created by Eric on 17/04/2017.
//
//

import XCTest
import RxSwift

class BoilerServiceTests: XCTestCase {
    
    var initialTemperature = 60.0
    let boilerService = BoilerService(httpClient: HttpClient(), repeatTimer: RepeatTimer(delay:5))
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        _ = boilerService.temperatureObserver.subscribe(onNext: { (temperature:Double) in
            self.initialTemperature = temperature
        })
        sleep(5)
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        boilerService.temperaturePublisher.onNext(initialTemperature)
        
        super.tearDown()
    }
    
    
    func testSetGetTemperature()
    {
        boilerService.temperaturePublisher.onNext(75.0)
        sleep(5)
       let expectation = self.expectation(description: "Handler called")
        _ = boilerService.temperatureObserver.subscribe(onNext: { (temperature:Double) in
            print(temperature)
            XCTAssertTrue(temperature == 75.0)
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 10) { (error:Error?) in print(error as Any)}
    }
 
}
