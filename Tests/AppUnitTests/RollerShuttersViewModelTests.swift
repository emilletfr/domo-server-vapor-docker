//
//  RollerShuttersViewModelTests.swift
//  VaporApp
//
//  Created by Eric on 24/12/2016.
//
//

import XCTest
import Foundation
import Dispatch
import Vapor
import HTTP
import RxSwift


class RollerShuttersViewModelTests: XCTestCase {
    
    
let rollerShuttersViewModel = RollerShuttersViewModel()
    
    func _testExample()
    {
      //  let expectation = self.expectation(description: "Handler called")
/*
        _ = rollerShuttersViewModel.currentAllPositionObserver.debug("P")
            .map({$0 == 0 ? 100 : 0}).debug("Q")
            .subscribe(rollerShuttersViewModel.targetAllPositionPublisher)
        sleep(10)
        _ = Observable.combineLatest(rollerShuttersViewModel.currentAllPositionObserver, rollerShuttersViewModel.targetAllPositionObserver, resultSelector: {$0 == $1}).filter({$0 == true}).subscribe(onNext: { ok in expectation.fulfill() })
 */
     //   rollerShuttersViewModel.targetAllPositionPublisher.onNext(0)
      //  self.waitForExpectations(timeout: 600) { (error:Error?) in print(error as Any)}
    }
    
    
}
