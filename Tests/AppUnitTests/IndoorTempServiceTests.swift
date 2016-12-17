//
//  IndoorTempServiceTests.swift
//  VaporApp
//
//  Created by Eric on 17/12/2016.
//
//

import XCTest

class IndoorTempServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetrieveTemperatureAndHumidity() {
        let expectation = self.expectation(description: "Handler called")
        _ = IndoorTempService(completion: { (degres:Double?, humidity:Int?) in
            XCTAssertNotNil(degres)
            XCTAssertNotNil(humidity)
            print("Indoor temp: \(degres as Any), humidity:  \(humidity as Any)")
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 10) { (error:Error?) in print(error as Any)}
    }
}
