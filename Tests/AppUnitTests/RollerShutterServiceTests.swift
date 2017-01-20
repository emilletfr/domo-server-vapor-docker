//
//  RollerShutterServiceTest.swift
//  VaporApp
//
//  Created by Eric on 15/12/2016.
//
//

import XCTest
import Foundation
import Dispatch
import Vapor
import HTTP
import RxSwift

class RollerShutterServiceTest: XCTestCase {
    
    let rollerShutterService = RollerShutterService()
    func testRetrieveIsOpen()
    {
        let expectation = self.expectation(description: "Handler called")
        
        _  = rollerShutterService.currentPositionObserver[Place.LIVING_ROOM.rawValue].subscribe { (event) in
            print(event)
            XCTAssertNil(event.error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { (error:Error?) in print(error as Any)}
 
    }
    
//let rollerShutterService = RollerShutterService(.LIVING_ROOM)
    
    func _testClose()
    {
   //     let targetPos = 100
      //  let expectation = self.expectation(description: "Handler called")
     //   var initStatePassed = false
        
       // rollerShutterService.targetPositionPublisher[3].onNext(0)
        
    //    _ = self.rollerShutterService.currentPositionObserver[Place.LIVING_ROOM.rawValue].map({$0 < 50 ? 100 : 0}).take(2).subscribe(rollerShutterService.targetPositionPublisher[Place.LIVING_ROOM.rawValue])
        
        /*
        self.rollerShutterService.targetPositionPublisher.onNext(targetPos)
        _ = self.rollerShutterService.currentPositionObserver.subscribe(onNext:
            {
                if initStatePassed == true {XCTAssertEqual($0, targetPos);expectation.fulfill()}
                initStatePassed = true
        } )
 */

  //  self.waitForExpectations(timeout: 50) { (error:Error?) in print(error as Any)}
    }


}





