//
//  RollerShutterServiceTest.swift
//  VaporApp
//
//  Created by Eric on 15/12/2016.
//
//

import XCTest

class RollerShutterServiceTest: XCTestCase {
    
    // var rollerShutterService : RollerShutterService?
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetrieveIsOpen()
    {
        let expectation = self.expectation(description: "Handler called")
        let rollerShutterService = RollerShutterService(rollerShutterIndex: 0)
        rollerShutterService.retrieveStatus(statusOnCompletion: { (open:Bool?) in
            print("isOpen : \(open)")
            XCTAssertNotNil(open)
            expectation.fulfill()
        })
        
         self.waitForExpectations(timeout: 5) { (error:Error?) in print(error as Any)}
    }
    
    
    func _testCloseRullerShutters()
    {
        let expectation = self.expectation(description: "Handler called")
        let rollerShutterService = RollerShutterService(rollerShutterIndex: 0)
        rollerShutterService.moveToPosition(targetPosition: 5) { (Void) in
            print("rollerShutterService.currentPosition: \(rollerShutterService.currentPosition)")
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 30) { (error:Error?) in print("wait")}
        print("rollerShutterService.currentPosition: \(rollerShutterService.currentPosition)")
    }
 
    
    
}
