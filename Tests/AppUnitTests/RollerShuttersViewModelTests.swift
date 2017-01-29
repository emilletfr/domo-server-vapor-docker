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
//@testable import VaporApp


class RollerShuttersViewModelTests: XCTestCase {
    
   // static let allTests = [("testSunriseSunset", testSunriseSunset)]
    
    func testSunriseSunset()
    {
        let expectation = self.expectation(description: "Handler called")
        // Init Dependencies
        let mockRollerShutterService = MockRollerShutterService()
        let mockInBedService = MockInBedService()
        let mockSunriseSunsetService = MockSunriseSunsetService()
        let mockTimePublisher = PublishSubject<String>()
        // Init view model
        let viewModel = RollerShuttersViewModel(mockRollerShutterService, mockInBedService, mockSunriseSunsetService, mockTimePublisher)
        _ = viewModel.manualAutomaticModePublisher.onNext(0)
        let shuttersObservable = Observable.of(
            mockRollerShutterService.targetPositionPublisher[Place.LIVING_ROOM.rawValue].map{(0,$0)},
            mockRollerShutterService.targetPositionPublisher[Place.DINING_ROOM.rawValue].map{(1,$0)},
            mockRollerShutterService.targetPositionPublisher[Place.OFFICE.rawValue].map{(2,$0)},
            mockRollerShutterService.targetPositionPublisher[Place.KITCHEN.rawValue].map{(3,$0)},
            mockRollerShutterService.targetPositionPublisher[Place.BEDROOM.rawValue].map{(4,$0)})
            .merge()
        mockSunriseSunsetService.sunriseTimeObserver.onNext("08:00")
        mockSunriseSunsetService.sunsetTimeObserver.onNext("20:00")
        
        // Test if all Roller Shutters except in bedroom open at sunrise
        var sequence = [Int:Int]()
        let open = shuttersObservable.subscribe(onNext:{sequence[$0.0] = $0.1})
        mockTimePublisher.onNext("08:00")
        usleep(1_000)
        XCTAssert(sequence == [Place.LIVING_ROOM.rawValue:100,Place.DINING_ROOM.rawValue:100,Place.OFFICE.rawValue:100,Place.KITCHEN.rawValue:100]);
        open.dispose()
        
        // Test if all Roller Shutters close at sunset
        sequence = [Int:Int]()
        let close = shuttersObservable.subscribe(onNext:{sequence[$0.0] = $0.1})
        mockTimePublisher.onNext("20:00")
        usleep(1_000)
        XCTAssert(sequence == [Place.LIVING_ROOM.rawValue:0,Place.DINING_ROOM.rawValue:0,Place.OFFICE.rawValue:0,Place.KITCHEN.rawValue:0, Place.BEDROOM.rawValue:0]);
        close.dispose()
        
        // Test if nothing happens the rest of the time
        sequence = [Int:Int]()
        let impossible = shuttersObservable.subscribe(onNext:{sequence[$0.0] = $0.1})
        for hour in 0...23 {
            for minute in 0...59 {
                let time = "".appendingFormat("%02d:%02d", hour,minute)
                if time != "08:00" && time != "20:00" {mockTimePublisher.onNext(time)}
            }
        }
        usleep(1_000)
        XCTAssert(sequence.count == 0);
        impossible.dispose()
        expectation.fulfill()
        
        self.waitForExpectations(timeout:0.1) { (error:Error?) in print(error as Any)}
    }
}
