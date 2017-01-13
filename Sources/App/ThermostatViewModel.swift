//
//  ThermostatViewModel.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import Foundation
import RxSwift
import Dispatch

enum HeatingCoolingState: Int { case OFF = 0, HEAT, COOL, AUTO }

protocol ThermostatViewModelable
{
    var currentOutdoorTemperatureObserver : BehaviorSubject<Int> {get}
    var currentIndoorTemperatureObserver : BehaviorSubject<Int> {get}
    var targetIndoorTemperatureObserver : BehaviorSubject<Int> {get}
    var currentHeatingCoolingStateObserver : BehaviorSubject<HeatingCoolingState> {get}
    var targetHeatingCoolingStateObserver : BehaviorSubject<HeatingCoolingState> {get}
    
    var targetTemperaturePublisher : BehaviorSubject<Int> {get}
    var targetHeatingCoolingStatePublisher : BehaviorSubject<HeatingCoolingState> {get}
    
    init(indoorTempService:IndoorTempServiceable, inBedService:InBedServicable)
}

class ThermostatViewModel : ThermostatViewModelable
{
    var currentOutdoorTemperatureObserver = BehaviorSubject<Int>(value:20)
    var currentHeatingCoolingStateObserver = BehaviorSubject<HeatingCoolingState>(value: .OFF)
    var targetHeatingCoolingStateObserver = BehaviorSubject<HeatingCoolingState>(value: .OFF)
    var currentIndoorTemperatureObserver = BehaviorSubject<Int>(value:20)
    var targetIndoorTemperatureObserver = BehaviorSubject<Int>(value: 20)
    
    var targetTemperaturePublisher = BehaviorSubject<Int>(value:20)
    var targetHeatingCoolingStatePublisher = BehaviorSubject<HeatingCoolingState>(value:.OFF)
    
    var indoorTempService : IndoorTempServiceable!
    var inBedService : InBedServicable!
    
    required init(indoorTempService:IndoorTempServiceable = IndoorTempService(), inBedService:InBedServicable = InBedService())
    {
        self.indoorTempService = indoorTempService
        self.inBedService = inBedService
        
        let servicesObservable = Observable.combineLatest(indoorTempService.degres, inBedService.isInBed) { (indoorDeg, isInBed) in return (indoorDeg, isInBed)}
        let publishObservable = Observable.combineLatest(targetTemperaturePublisher, targetHeatingCoolingStatePublisher) { (targetTemperature, targetHeatingCoolingState) in return (targetTemperature, targetHeatingCoolingState)}
        let overallObservable = Observable.combineLatest(servicesObservable, publishObservable) { (a, b) in return (a.0,a.1,b.0,b.1)}
        let overallFilteredObservable = overallObservable.distinctUntilChanged({ (old: (Double, Bool, Int, HeatingCoolingState), new: (Double, Bool, Int, HeatingCoolingState)) -> Bool in old == new
        }).throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
        
        _ = overallFilteredObservable.subscribe(onNext: { (indoorDegres:Double, isInbed:Bool, targetTemp:Int, targetHeatingCoolingState:HeatingCoolingState) in
            print(indoorDegres)
            self.currentIndoorTemperatureObserver.onNext(Int(indoorDegres >= 0 ? indoorDegres : 0))
            if targetHeatingCoolingState == .OFF
            {
                self.targetIndoorTemperatureObserver.onNext(10)
            }
            else if isInbed == true
            {
                let tempMinusTwo = targetTemp - 2
                self.targetIndoorTemperatureObserver.onNext(tempMinusTwo >= 10 ? tempMinusTwo : 10)
            }
            else
            {
                self.targetIndoorTemperatureObserver.onNext(targetTemp >= 10 ? targetTemp : 10)
            }
            self.currentHeatingCoolingStateObserver.onNext(targetHeatingCoolingState != .AUTO ? targetHeatingCoolingState : .HEAT)
            self.targetHeatingCoolingStateObserver.onNext(targetHeatingCoolingState != .AUTO ? targetHeatingCoolingState : .HEAT)
        })
    }
}
