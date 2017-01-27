//
//  ThermostatViewModel.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import RxSwift
import Foundation


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
    var forcingWaterHeaterObserver : PublishSubject<Int> {get}
    var boilerHeatingLevelObserver : PublishSubject<Int> {get}
    //MARK: Actions
    var targetTemperaturePublisher : PublishSubject<Int> {get}
    var targetHeatingCoolingStatePublisher : PublishSubject<HeatingCoolingState> {get}
    var forcingWaterHeaterPublisher : PublishSubject<Int> {get}
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
    let forcingWaterHeaterObserver = PublishSubject<Int>()
    let boilerHeatingLevelObserver = PublishSubject<Int>()
    //MARK: Actions
    let targetTemperaturePublisher = PublishSubject<Int>()
    let targetHeatingCoolingStatePublisher = PublishSubject<HeatingCoolingState>()
    let forcingWaterHeaterPublisher = PublishSubject<Int>()
    //MARK: Dependencies
    let outdoorTempService : OutdoorTempServicable
    let indoorTempService : IndoorTempServicable
    let inBedService : InBedServicable
    let boilerService : BoilerServicable
    var boilerHeatingLevelMemorySpan = 3600.0*24.0
    
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
        let computedIndoorTemp = indoorTempService.temperatureObserver.map{$0/* - 0.2*/}
        
        // Compute target temp following isInBed, target cooling state
        let computedTargetTemp = Observable<Int>.combineLatest(inBedService.isInBedObserver, targetTemperaturePublisher, targetHeatingCoolingStatePublisher, resultSelector: { (isInbed:Bool, targetTemp:Int, targetHeatingCoolingState:HeatingCoolingState) -> Int in
            if isInbed == true {return targetTemp - 2}
            if targetHeatingCoolingState == .OFF {return 7}
            return targetTemp})
            .distinctUntilChanged()
        
        //MARK: Wrap Outdoor Temperature (HomeKit do not support temperature < 0°C from temperature sensors)
        _ = outdoorTempService.temperatureObserver
            .map{Int($0 < 0 ? 0 : $0)}
            .subscribe(self.currentOutdoorTemperatureObserver)
        
        //MARK: Wrap Indoor temperature (HomeKit do not support temperature < 0°C from temperature sensors)
        _ = computedIndoorTemp
            .distinctUntilChanged().debug("computedIndoorTemperature")
            .map{Int($0 < 0 ? 0 : $0)}
            .subscribe(self.currentIndoorTemperatureObserver)
        
        //MARK: Wrap Indoor Humidity
        _ = indoorTempService.humidityObserver
            .map{Int($0)}
            .subscribe(self.currentIndoorHumidityObserver)
        
        //MARK: Wrap Thermostat Temperature (HomeKit do not support thermostat target temperature < 10)
        _ = computedTargetTemp.debug("computedTargetTemperature")
            .map {Int($0 < 10 ? 10 : $0)}
            .subscribe(self.targetIndoorTemperatureObserver)
        
        //MARK: Wrap Force Hot Water Observer
        _ = forcingWaterHeaterPublisher.debug("forceHotWaterPublisher")
            .subscribe(forcingWaterHeaterObserver)
        
        //MARK: Wrap Heater's Boiler
        let computedBoilerHeating = Observable<Bool>.combineLatest(targetHeatingCoolingStatePublisher, outdoorTempService.temperatureObserver, computedTargetTemp, forcingWaterHeaterPublisher) { (targetHeatingCooling:HeatingCoolingState, outdoorTemp:Double, computedTargetTemp:Int, forcingWaterHeater:Int ) in
            if forcingWaterHeater == 1 {return true}
            else {return targetHeatingCooling != .OFF && outdoorTemp < Double(computedTargetTemp)}
            }.debug("computedBoilerHeating")
        
        _ = computedBoilerHeating.debug("computedBoilerHeating")
            .distinctUntilChanged()
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).debug("heaterPublisher")
            .subscribe(boilerService.heaterPublisher)
        
        //MARK: Wrap Pomp's Boiler
        let computedBoilerPomping =  Observable<Bool>
            .combineLatest(computedBoilerHeating, computedIndoorTemp, computedTargetTemp)
            {( computedBoilerHeating:Bool, computedIndoorTemp:Double, computedTargetTemp:Int) in
                return computedIndoorTemp < Double(computedTargetTemp) && computedBoilerHeating == true
            }.distinctUntilChanged()
        
        _ = computedBoilerPomping.debug("computedBoilerPomping")
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).debug("pompPublisher")
            .subscribe(boilerService.pompPublisher)
        
        //MARK: Wrap HomeKit Heating Cooling State
        let computedHeatingCoolingState = Observable<HeatingCoolingState>.combineLatest(computedBoilerHeating, computedBoilerPomping)
        {(computedBoilerHeating:Bool, computedBoilerPomping:Bool) in
            return computedBoilerHeating == true ? ( computedBoilerPomping ? .HEAT : .COOL ) : .OFF
        }
        
        _ = computedHeatingCoolingState.subscribe(self.currentHeatingCoolingStateObserver)
        _ = computedHeatingCoolingState.subscribe(self.targetHeatingCoolingStateObserver)
        
        //MARK: Wrap Boiler Heating Level 
        // IndoorTemp (°C) > Boiler Heater Level (%)  - 20.0°C = 0%  - 20.4°C = 100%
        // Collect max values when indoor temp > 20.0 and target temp = 20
        // Add timestamp to collected max values and calculate average max value since last 24h
        var localComputedBoilerHeating = false
        _ = computedBoilerHeating.subscribe(onNext:{ localComputedBoilerHeating = $0})
        var localComputedTargetTemp = 0
        _ = computedTargetTemp.subscribe(onNext:{ localComputedTargetTemp = $0})
        
        // Collect Max temp when Boiler is heating, Target temp = 20
        var maxTemp : Double?
        let maxTempObservable = computedIndoorTemp.map { (indoorTemperature:Double) -> Double? in
            if localComputedBoilerHeating == true && localComputedTargetTemp == 20
            {
                if indoorTemperature >= 20.0
                {
                    if maxTemp == nil {maxTemp = 0.0}
                    maxTemp = indoorTemperature > maxTemp! ? indoorTemperature : maxTemp!
                }
                else {let returnMaxTemp = maxTemp; maxTemp = nil; return returnMaxTemp}
            }
            return nil
        }
        
        // Add timestamp to Max Temps
        var dateForMaxTemperatureCollection = [Date: Double]()
        var totalAverage = 0
        
        let filteredDateForMaxTemperature = maxTempObservable.map({ (maxTemperature:Double?) -> Int? in
            // Remove obsoletes ones in collection
            for (date,_) in dateForMaxTemperatureCollection {
                if date.timeIntervalSinceNow < -self.boilerHeatingLevelMemorySpan {dateForMaxTemperatureCollection.removeValue(forKey: date)}}
            if let maxTemperature = maxTemperature
            {
                // Add maxTemperature to timestamp collection
                dateForMaxTemperatureCollection[Date()] = maxTemperature
                // Compute average
                let total = dateForMaxTemperatureCollection.values.reduce(0.0, { (a, b) in return a+b})
                let average = (total)/Double(dateForMaxTemperatureCollection.values.count)
                var computedAverage = round((average-20)*100/0.4)
                if computedAverage < 0 {computedAverage = 0}
                else if computedAverage > 100 {computedAverage = 100}
                totalAverage = Int(computedAverage)
            }
            if dateForMaxTemperatureCollection.count == 0 {totalAverage = 0}
            return totalAverage
        })
        _ = filteredDateForMaxTemperature.filter {$0 != nil}.map{$0!}.distinctUntilChanged().subscribe(boilerHeatingLevelObserver)
    }
}
