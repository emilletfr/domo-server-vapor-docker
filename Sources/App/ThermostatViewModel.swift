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
    var hotWaterObserver : PublishSubject<Int> {get}
    //MARK: Actions
    var targetTemperaturePublisher : PublishSubject<Int> {get}
    var targetHeatingCoolingStatePublisher : PublishSubject<HeatingCoolingState> {get}
    var hotWaterPublisher : PublishSubject<Int> {get}
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
    let hotWaterObserver = PublishSubject<Int>()
    //MARK: Actions
    let targetTemperaturePublisher = PublishSubject<Int>()
    let targetHeatingCoolingStatePublisher = PublishSubject<HeatingCoolingState>()
    var hotWaterPublisher = PublishSubject<Int>()
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
            .distinctUntilChanged()
        
        // Wrap Outdoor Temperature (HomeKit do not support temperature < 0°C from temperature sensors)
        _ = outdoorTempService.temperatureObserver
            .map{Int($0 < 0 ? 0 : $0)}
            .subscribe(self.currentOutdoorTemperatureObserver)
        
        // Wrap Indoor temperature (HomeKit do not support temperature < 0°C from temperature sensors)
        _ = indoorTempReducer
            .distinctUntilChanged().debug("computedIndoorTemperature")
            .map{Int($0 < 0 ? 0 : $0)}
            .subscribe(self.currentIndoorTemperatureObserver)
        
        // Wrap Indoor Humidity
        _ = indoorTempService.humidityObserver
            .map{Int($0)}
            .subscribe(self.currentIndoorHumidityObserver)
        
        // Wrap Thermostat Temperature (HomeKit do not support thermostat target temperature < 10)
        _ = targetTempReducer.debug("computedTargetTemperature")
            .map {Int($0 < 10 ? 10 : $0)}
            .subscribe(self.targetIndoorTemperatureObserver)
        
        // Compare current temperature and target temperature
        let heatingOrCoolingReducer = Observable<Bool>
            .combineLatest(indoorTempReducer, targetTempReducer) {$0 < Double($1)}
            .distinctUntilChanged()
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
        
        // Wrap Force Hot Water Observer
        _ = hotWaterPublisher.debug("forceHotWaterPublisher")
            .subscribe(hotWaterObserver)
        
        // Wrap Heater's Boiler
        _ = Observable<Bool>.combineLatest(targetHeatingCoolingStatePublisher, outdoorTempService.temperatureObserver, targetTempReducer, hotWaterPublisher) { (targetHeatingCooling:HeatingCoolingState, outdoorTemp:Double, targetTemp:Int, hotWater:Int ) in
            if hotWater == 1 {return true}
            else {return !(targetHeatingCooling == .OFF || outdoorTemp > Double(targetTemp))}
            }
            .distinctUntilChanged().debug("heaterPublisher")
            .subscribe(boilerService.heaterPublisher)
        
        // Wrap Pomp's Boiler
        _ = heatingOrCoolingReducer.debug("pompPublisher")
            .subscribe(boilerService.pompPublisher)
        
        // Wrap HomeKit Heating Cooling State
        let heatingCoolingStateReducer = Observable<HeatingCoolingState>.combineLatest(targetHeatingCoolingStatePublisher, heatingOrCoolingReducer)
        {$0 == .OFF ? .OFF : ($1 == true ? .HEAT : .COOL)}
        _ = heatingCoolingStateReducer.subscribe(self.currentHeatingCoolingStateObserver)
        _ = heatingCoolingStateReducer.subscribe(self.targetHeatingCoolingStateObserver)
    }
}
