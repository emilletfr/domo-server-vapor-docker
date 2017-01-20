//
//  ThermostatViewModel.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import RxSwift


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
    init(outdoorTempService:OutdoorTempServicable, indoorTempService:IndoorTempServicable, inBedService:InBedServicable, boilerService:BoilerServicable)
}


final class ThermostatViewModel : ThermostatViewModelable
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
    let outdoorTempService : OutdoorTempServicable
    let indoorTempService : IndoorTempServicable
    let inBedService : InBedServicable
    let boilerService : BoilerServicable
    
    //MARK: Dispatcher
    required init(outdoorTempService:OutdoorTempServicable = OutdoorTempService(), indoorTempService:IndoorTempServicable = IndoorTempService(), inBedService:InBedServicable = InBedService(), boilerService:BoilerServicable = BoilerService())
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
        // Adjust indoor temperature offset
        let indoorTempReducer = indoorTempService.temperatureObserver.map{$0 - 0.2}
        
        // Compute target temp following isInBed, target cooling state
        let targetTempReducer = Observable.combineLatest(inBedService.isInBedObserver, targetTemperaturePublisher, targetHeatingCoolingStatePublisher, resultSelector: { (isInbed:Bool, targetTemp:Int, targetHeatingCoolingState:HeatingCoolingState) -> Int in
            if isInbed == true {return targetTemp - 2}
            if targetHeatingCoolingState == .OFF {return 7}
            return targetTemp})
        
        // Combine latest, distinct until changed and thottle all inputs
        let combineReducer  = Observable
            .combineLatest(outdoorTempService.temperatureObserver, indoorTempReducer, indoorTempService.humidityObserver, targetHeatingCoolingStatePublisher, targetTempReducer){$0}
            .distinctUntilChanged{$0 == $1}
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
        
        typealias Data = (outdoorTemp:Double, computedIndoorTemp:Double, indoorHumidity:Int, targetHeatingCoolingState:HeatingCoolingState, computedTargetTemp:Int)
        
        // Wrap Outdoor Temperature (HomeKit do not support temperature < 0°C from temperature sensors)
        _ = combineReducer.map {
            Int(($0 as Data).outdoorTemp >= 0 ? ($0 as Data).outdoorTemp:0)}.subscribe(self.currentOutdoorTemperatureObserver)
        
        // Wrap Indoor temperature (HomeKit do not support temperature < 0°C from temperature sensors)
        _ = combineReducer.map {
            Int(($0 as Data).computedIndoorTemp >= 0 ? ($0 as Data).computedIndoorTemp:0)}.subscribe(self.currentIndoorTemperatureObserver)
        
        // Wrap Indoor Humidity
        _ = combineReducer.map {Int(($0 as Data).indoorHumidity) }.subscribe(self.currentIndoorHumidityObserver)
        
        // Wrap Thermostat Temperature (HomeKit do not support thermostat target temperature < 10)
        _ = combineReducer.map {
            ($0 as Data).computedTargetTemp >= 10 ? ($0 as Data).computedTargetTemp:10}.subscribe(self.targetIndoorTemperatureObserver)
        
        // Wrap Thermostat Current State
        _ = combineReducer.map {
            let itsCold = ($0 as Data).computedIndoorTemp < Double(($0 as Data).computedTargetTemp)
            return ($0 as Data).targetHeatingCoolingState == .OFF ? .OFF : (itsCold == true ? .HEAT : .COOL)
            }.subscribe(self.currentHeatingCoolingStateObserver)
        
        // Wrap Thermostat Target State
        _ = combineReducer.map
            {
                let itsCold = ($0 as Data).computedIndoorTemp < Double(($0 as Data).computedTargetTemp)
                self.boilerService.forceHeater(OnOrOff: itsCold)
                self.boilerService.forcePomp(OnOrOff: itsCold)
                return ($0 as Data).targetHeatingCoolingState == .OFF ? .OFF : (itsCold == true ? .HEAT : .COOL)
            }.subscribe(self.targetHeatingCoolingStateObserver)
        
        
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


