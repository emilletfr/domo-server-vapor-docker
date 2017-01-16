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
    //MARK: Subscribers
    var currentOutdoorTemperatureObserver : PublishSubject<Int> {get}
    var currentIndoorHumidityObserver : PublishSubject<Int> {get}
    var currentIndoorTemperatureObserver : PublishSubject<Int> {get}
    var targetIndoorTemperatureObserver : PublishSubject<Int> {get}
    var currentHeatingCoolingStateObserver : PublishSubject<HeatingCoolingState> {get}
    var targetHeatingCoolingStateObserver : PublishSubject<HeatingCoolingState> {get}
    //MARK: Actions
    var targetTemperaturePublisher : PublishSubject<Int> {get}
    var targetHeatingCoolingStatePublisher : PublishSubject<HeatingCoolingState> {get}
    //MARK: Dispatcher
    init(outdoorTempService:OutdoorTempServiceable, indoorTempService:IndoorTempServiceable, inBedService:InBedServicable, boilerService:BoilerServicable)
}

class ThermostatViewModel : ThermostatViewModelable
{
    //MARK: Subscribers
    let currentOutdoorTemperatureObserver = PublishSubject<Int>()
    let currentIndoorHumidityObserver = PublishSubject<Int>()
    let currentIndoorTemperatureObserver = PublishSubject<Int>()
    let targetIndoorTemperatureObserver = PublishSubject<Int>()
    let currentHeatingCoolingStateObserver = PublishSubject<HeatingCoolingState>()
    let targetHeatingCoolingStateObserver = PublishSubject<HeatingCoolingState>()
    //MARK: Actions
    let targetTemperaturePublisher = PublishSubject<Int>()
    let targetHeatingCoolingStatePublisher = PublishSubject<HeatingCoolingState>()
    //MARK: Dependencies
    let outdoorTempService : OutdoorTempServiceable
    let indoorTempService : IndoorTempServiceable
    let inBedService : InBedServicable
    let boilerService : BoilerServicable
    
    //MARK: Dispatcher
     required init(outdoorTempService:OutdoorTempServiceable = OutdoorTempService(), indoorTempService:IndoorTempServiceable = IndoorTempService(), inBedService:InBedServicable = InBedService(), boilerService:BoilerServicable = BoilerService())
    {
        self.outdoorTempService = outdoorTempService
        self.indoorTempService = indoorTempService
        self.inBedService = inBedService
        self.boilerService = boilerService
        self.reduce()
    }
    
    //MARK: Reducer
    func reduce()
    {
        let indoorTempReducer = indoorTempService.temperatureObserver.map {$0 - 0.2}
        let targetTempReducer = Observable.combineLatest(inBedService.isInBedObserver, targetTemperaturePublisher, targetHeatingCoolingStatePublisher, resultSelector: { (isInbed:Bool, targetTemp:Int, targetHeatingCoolingState:HeatingCoolingState) -> Int in
            if isInbed == true {return targetTemp - 2}
            if targetHeatingCoolingState == .OFF {return 7}
            return targetTemp})
        let combineReducer  = Observable
            .combineLatest(outdoorTempService.temperatureObserver, indoorTempReducer, indoorTempService.humidityObserver, targetHeatingCoolingStatePublisher, targetTempReducer){$0}
            .distinctUntilChanged({$0 == $1})
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
        
        typealias Data = (outdoorTemp:Double, computedIndoorTemp:Double, indoorHumidity:Int, targetHeatingCoolingState:HeatingCoolingState, computedTargetTemp:Int)
        
        _ = combineReducer.map {
            Int(($0 as Data).outdoorTemp) }.debug().subscribe(self.currentOutdoorTemperatureObserver)
        _ = combineReducer.map {
            Int(($0 as Data).computedIndoorTemp >= 0 ? ($0 as Data).computedIndoorTemp:0) }.debug().subscribe(self.currentIndoorTemperatureObserver)
        _ = combineReducer.map {
            Int(($0 as Data).indoorHumidity) }.debug().subscribe(self.currentIndoorHumidityObserver)
        _ = combineReducer.map {
            ($0 as Data).computedIndoorTemp >= 10 ? Int(($0 as Data).computedIndoorTemp):10}.debug().subscribe(self.currentIndoorTemperatureObserver)
        _ = combineReducer.map {
            ($0 as Data).computedTargetTemp >= 10 ? ($0 as Data).computedTargetTemp:10}.debug().subscribe(self.targetIndoorTemperatureObserver)
        _ = combineReducer.map {
            let itsCold = ($0 as Data).computedIndoorTemp < Double(($0 as Data).computedTargetTemp)
            return ($0 as Data).targetHeatingCoolingState == .OFF ? .OFF : (itsCold == true ? .HEAT : .COOL)
            }.debug().subscribe(self.currentHeatingCoolingStateObserver)
        _ = combineReducer.map {
            let itsCold = ($0 as Data).computedIndoorTemp < Double(($0 as Data).computedTargetTemp)
            //        self?.boilerService.forceHeater(OnOrOff: itsCold)
            //       self?.boilerService.forcePomp(OnOrOff: itsCold)
            return ($0 as Data).targetHeatingCoolingState == .OFF ? .OFF : (itsCold == true ? .HEAT : .COOL)
            }.debug().subscribe(self.targetHeatingCoolingStateObserver)
 
        
        /*
         .subscribe(onNext: {[weak self] (data:(outdoorTemp:Double, computedIndoorTemp:Double, indoorHumidity:Int, targetHeatingCoolingState:HeatingCoolingState, computedTargetTemp:Int)) in
         // print(data)
         self?.currentIndoorHumidityObserver.onNext(data.indoorHumidity)
         self?.currentIndoorTemperatureObserver.onNext(Int(data.computedIndoorTemp >= 0 ? data.computedIndoorTemp : 0))
         self?.targetIndoorTemperatureObserver.onNext(data.computedTargetTemp >= 10 ? data.computedTargetTemp : 10)
         let itsCold = data.computedIndoorTemp < Double(data.computedTargetTemp)
         self?.currentHeatingCoolingStateObserver.onNext(data.targetHeatingCoolingState == .OFF ? .OFF : (itsCold == true ? .HEAT : .COOL))
         self?.targetHeatingCoolingStateObserver.onNext(data.targetHeatingCoolingState == .OFF ? .OFF : (itsCold == true ? .HEAT : .COOL))
         //        self?.boilerService.forceHeater(OnOrOff: itsCold)
         //       self?.boilerService.forcePomp(OnOrOff: itsCold)
         })
         */
    }
}


