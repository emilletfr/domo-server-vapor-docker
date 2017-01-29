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
//@testable import VaporApp


class ThermostatViewModelTests: XCTestCase
{
    
    static let allTests = [("testBoilerHeatingLevel", testBoilerHeatingLevel)]
    
    var thermostatViewModel : ThermostatViewModel?
    
    func testBoilerHeatingLevel()
    {
        let expectation = self.expectation(description: "Handler called")
        // Init Dependencies
        let mockOutdoorTempService = MockOutdoorTempService()
        let mockIndoorTempService = MockIndoorTempService()
        let mockInBedService = MockInBedService()
        let mockBoilerService = MockBoilerService()
        // Init view model
        thermostatViewModel = ThermostatViewModel(outdoorTempService: mockOutdoorTempService, indoorTempService: mockIndoorTempService, inBedService: mockInBedService, boilerService: mockBoilerService)
        
        // test returned values
        thermostatViewModel?.boilerHeatingLevelMemorySpan = 0.05 // 50ms for testing purpose
        var expectedBoilerHeatingLevels = [0, 100, 75, 50, 0]  // Expected sequence
        _ = thermostatViewModel?.boilerHeatingLevelObserver.subscribe(onNext: { (level:Int) in
            XCTAssertEqual(level, expectedBoilerHeatingLevels[0]); print(level)
            expectedBoilerHeatingLevels = Array(expectedBoilerHeatingLevels.dropFirst())
            if expectedBoilerHeatingLevels.isEmpty == true {expectation.fulfill()}
        })
        
        thermostatViewModel?.targetTemperaturePublisher.onNext(20) //Valid target temp for mesuring Boiler Heating Level
        thermostatViewModel?.targetHeatingCoolingStatePublisher.onNext(HeatingCoolingState.HEAT) // Initial value
        thermostatViewModel?.forcingWaterHeaterPublisher.onNext(0) // Normal setup
        mockInBedService.isInBedObserver.onNext(false) // Not in bed in order to keep target temp to 20°C vs 18°C if in bed
        mockOutdoorTempService.temperatureObserver.onNext(15) // Outdoor temp < 20°C in order to make boiler work
        let indoorTemp = mockIndoorTempService.temperatureObserver
        
        //   IndoorTemp (°C) > Boiler Heater Level (%)  - 20.0°C = 0%   -    20.4°C = 100%
        indoorTemp.onNext(15.0); usleep(1_000)
        indoorTemp.onNext(20.4); usleep(1_000) // 100%
        indoorTemp.onNext(19.9); usleep(1_000)
        
        indoorTemp.onNext(20.1); usleep(1_000)
        indoorTemp.onNext(20.2); usleep(1_000) // (100% + 50%)/2 = 150%
        indoorTemp.onNext(20.0); usleep(1_000)
        indoorTemp.onNext(20.1); usleep(1_000)
        indoorTemp.onNext(19.9); usleep(1_000)
        
        indoorTemp.onNext(20.0); usleep(1_000) // (100% + 50% + 0%)/3 = 50%
        indoorTemp.onNext(19.9); usleep(1_000)
        
        indoorTemp.onNext(19.0); usleep(1_000)
        usleep(50_000)                                         // boilerHeatingLevelMemorySpan = 50ms
        indoorTemp.onNext(19.0); usleep(1_000) // So all recorded values are deleted and result is 0%
        
        self.waitForExpectations(timeout: 0.100) { (error:Error?) in print(error as Any)}
    }
}
