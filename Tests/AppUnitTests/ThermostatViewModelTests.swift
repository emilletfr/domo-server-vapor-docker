//
//  ThermostatViewModelTests.swift
//  VaporApp
//
//  Created by Eric on 24/01/2017.
//
//

import XCTest
import Foundation
import Dispatch
import Vapor
import HTTP
import RxSwift


class ThermostatViewModelTests: XCTestCase
{
    var thermostatViewModel : ThermostatViewModel?
    
    func test()
    {
        let expectation = self.expectation(description: "Handler called")
        let mockOutdoorTempService = MockOutdoorTempService()
        let mockIndoorTempService = MockIndoorTempService()
        let mockInBedService = MockInBedService()
        let mockBoilerService = MockBoilerService()
        
        thermostatViewModel = ThermostatViewModel(outdoorTempService: mockOutdoorTempService, indoorTempService: mockIndoorTempService, inBedService: mockInBedService, boilerService: mockBoilerService)
        thermostatViewModel?.boilerHeatingLevelMemorySpan = 10
        let expectedBoilerHeatingLevels = [0, 100, 75, 67, 0]
        var count = 0
        _ = thermostatViewModel?.boilerHeatingLevelObserver.subscribe(onNext: { (level:Int) in
            print(level)
            XCTAssertEqual(level, expectedBoilerHeatingLevels[count])
            count += 1
            if count == expectedBoilerHeatingLevels.count {expectation.fulfill()}
        })
        
        thermostatViewModel?.targetTemperaturePublisher.onNext(20)
        thermostatViewModel?.targetHeatingCoolingStatePublisher.onNext(HeatingCoolingState.HEAT)
        thermostatViewModel?.forcingWaterHeaterPublisher.onNext(0)
        mockInBedService.isInBedObserver.onNext(false)
        mockOutdoorTempService.temperatureObserver.onNext(15)
        
        let indoorTemp = mockIndoorTempService.temperatureObserver
        
        //   IndoorTemp (°C) > Boiler Heater Level (%)  - 20.0°C = 0%   -    20.4°C = 100%
        indoorTemp.onNext(15.0); sleep(1)
        indoorTemp.onNext(20.4); sleep(1) // 100%
        indoorTemp.onNext(19.9); sleep(1)
        
        indoorTemp.onNext(20.0); sleep(1)
        indoorTemp.onNext(20.2); sleep(1) // (100% + 50%)/2 = 150%
        indoorTemp.onNext(19.0); sleep(1)
        
        indoorTemp.onNext(20.2); sleep(1) // (100% + 50% +50%)/3 = 67%
        indoorTemp.onNext(19.0); sleep(1)
        
        indoorTemp.onNext(19.0); sleep(1)
        sleep(10)                                         // boilerHeatingLevelMemorySpan = 10
        indoorTemp.onNext(19.0);sleep(1)  // So all values deleted > 0%
        
        self.waitForExpectations(timeout: 60) { (error:Error?) in print(error as Any)}
    }
}
