//
//  SunriseSunsetServiceTests.swift
//  VaporApp
//
//  Created by Eric on 17/12/2016.
//
//

import XCTest

class SunriseSunsetServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRetrieveSunriseAndSunset() {
          let expectation = self.expectation(description: "Handler called")
        _ = SunriseSunsetService { (sunrise:String?, sunset:String?) in
            XCTAssertNotNil(sunrise)
            XCTAssertNotNil(sunset)
             print("\(sunrise as Any) - \(sunset as Any)")
            expectation.fulfill()
        }
         self.waitForExpectations(timeout: 5) { (error:Error?) in print(error as Any)}
    }

}
