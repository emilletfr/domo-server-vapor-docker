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
    var currentOutdoorTemperatureObserver : PublishSubject<Int> {get}
    var currentIndoorHumidityObserver : PublishSubject<Int> {get}
    var currentIndoorTemperatureObserver : PublishSubject<Int> {get}
    var targetIndoorTemperatureObserver : PublishSubject<Int> {get}
    var currentHeatingCoolingStateObserver : PublishSubject<HeatingCoolingState> {get}
    var targetHeatingCoolingStateObserver : PublishSubject<HeatingCoolingState> {get}
    
    var targetTemperaturePublisher : PublishSubject<Int> {get}
    var targetHeatingCoolingStatePublisher : PublishSubject<HeatingCoolingState> {get}
    
    init(indoorTempService:IndoorTempServiceable, inBedService:InBedServicable)
}

class ThermostatViewModel : ThermostatViewModelable
{
    var currentOutdoorTemperatureObserver = PublishSubject<Int>()
    var currentIndoorHumidityObserver = PublishSubject<Int>()
    var currentIndoorTemperatureObserver = PublishSubject<Int>()
    var targetIndoorTemperatureObserver = PublishSubject<Int>()
    var currentHeatingCoolingStateObserver = PublishSubject<HeatingCoolingState>()
    var targetHeatingCoolingStateObserver = PublishSubject<HeatingCoolingState>()
    
    var targetTemperaturePublisher = PublishSubject<Int>()
    var targetHeatingCoolingStatePublisher = PublishSubject<HeatingCoolingState>()
    
    var indoorTempService : IndoorTempServiceable!
    var inBedService : InBedServicable!
    
    typealias InputData = (indoorTemp:Double, indoorHumidity:Int, isInbed:Bool, targetTemp:Int, targetHeatingCoolingState:HeatingCoolingState)
    
    required init(indoorTempService:IndoorTempServiceable = IndoorTempService(), inBedService:InBedServicable = InBedService())
    {
        self.indoorTempService = indoorTempService
        self.inBedService = inBedService
        let inputsObservable = Observable.combineLatest(indoorTempService.degresObserver, indoorTempService.humidityObserver, inBedService.isInBedObserver, targetTemperaturePublisher, targetHeatingCoolingStatePublisher){$0} as Observable<InputData>
        _ = inputsObservable.distinctUntilChanged({$0 == $1}).throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).subscribe(onNext: { data in
            print(data)
            self.currentIndoorTemperatureObserver.onNext(Int(data.indoorTemp >= 0 ? data.indoorTemp : 0))
            var computedTargetTemp = data.targetTemp
            if data.isInbed == true {computedTargetTemp = data.targetTemp - 2}
            if data.targetHeatingCoolingState == .OFF {computedTargetTemp = 7}
            
            self.targetIndoorTemperatureObserver.onNext(computedTargetTemp >= 10 ? computedTargetTemp : 10)
            let itsCold = data.indoorTemp < Double(computedTargetTemp)
            self.currentHeatingCoolingStateObserver.onNext(data.targetHeatingCoolingState == .OFF ? .OFF : (itsCold == true ? .HEAT : .COOL))
            self.targetHeatingCoolingStateObserver.onNext(data.targetHeatingCoolingState == .OFF ? .OFF : (itsCold == true ? .HEAT : .COOL))
        })
    }
}
