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
    var noPicDetectionDelayForBoilerTemperature : Double = 60*60
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
        //MARK: Wrap Outdoor Temperature
        _ = outdoorTempService.temperatureObserver
            .map{Int($0 < 0 ? 0 : $0)} // HomeKit do not support temperature < 0°C from temperature sensors
            .subscribe(self.currentOutdoorTemperatureObserver)
        
        //MARK: Wrap Indoor temperature
        _ = indoorTempService.temperatureObserver
            .distinctUntilChanged().debug("computedIndoorTemperature")
            .map{Int($0 < 0 ? 0 : $0)} // HomeKit do not support temperature < 0°C from temperature sensors
            .subscribe(self.currentIndoorTemperatureObserver)
        
        //MARK: Wrap Indoor Humidity
        _ = indoorTempService.humidityObserver
            .map{Int($0)}
            .subscribe(self.currentIndoorHumidityObserver)
        
        //MARK: Wrap Force Hot Water Observer
        _ = forcingWaterHeaterPublisher.debug("forceHotWaterPublisher")
            .subscribe(forcingWaterHeaterObserver)
        
        // Compute target temp following isInBed, target cooling state
        let computedTargetTemp = Observable<Int>.combineLatest(inBedService.isInBedObserver, targetTemperaturePublisher, targetHeatingCoolingStatePublisher, resultSelector: { (isInbed:Bool, targetTemp:Int, targetHeatingCoolingState:HeatingCoolingState) -> Int in
            if isInbed == true {return targetTemp - 2}
            if targetHeatingCoolingState == .OFF {return 7}
            return targetTemp})
            .distinctUntilChanged()
        
        //MARK: Wrap Thermostat Temperature
        _ = computedTargetTemp.debug("computedTargetTemperature")
            .map {Int($0 < 10 ? 10 : $0)} // HomeKit do not support thermostat target temperature < 10
            .subscribe(self.targetIndoorTemperatureObserver)
        
        //MARK: Wrap Heater's Boiler
        let computedBoilerHeating = Observable<Bool>.combineLatest(targetHeatingCoolingStatePublisher, outdoorTempService.temperatureObserver, computedTargetTemp, forcingWaterHeaterPublisher) { (targetHeatingCooling:HeatingCoolingState, outdoorTemp:Double, computedTargetTemp:Int, forcingWaterHeater:Int ) in
            if forcingWaterHeater == 1 {return true}
            else {return targetHeatingCooling != .OFF && outdoorTemp < Double(computedTargetTemp)}}
        
        _ = computedBoilerHeating
            .distinctUntilChanged()
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).debug("heaterPublisher")
            .subscribe(boilerService.heaterPublisher)
        
        //MARK: Wrap Pomp's Boiler
        let computedBoilerPomping =  Observable<Bool>
            .combineLatest(computedBoilerHeating, indoorTempService.temperatureObserver, computedTargetTemp)
            {(computedBoilerHeating:Bool, computedIndoorTemp:Double, computedTargetTemp:Int) in
                return computedIndoorTemp < Double(computedTargetTemp) && computedBoilerHeating == true
            }.distinctUntilChanged()
        
        _ = computedBoilerPomping
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).debug("pompPublisher")
            .subscribe(boilerService.pompPublisher)
        
        //MARK: Wrap HomeKit Heating Cooling State
        let computedHeatingCoolingState = Observable<HeatingCoolingState>
            .combineLatest(computedBoilerHeating, computedBoilerPomping) {(computedBoilerHeating:Bool, computedBoilerPomping:Bool) in
                return computedBoilerHeating == true ? ( computedBoilerPomping ? .HEAT : .COOL ) : .OFF
        }
        _ = computedHeatingCoolingState.subscribe(self.currentHeatingCoolingStateObserver)
        _ = computedHeatingCoolingState.subscribe(self.targetHeatingCoolingStateObserver)
        
        // MARK: Wrap Boiler Heating Level
        // IndoorTemp (°C) > Boiler Heater Level (%)  - 20.0°C = 0%  - 20.4°C = 100%
        // Collect max values when indoor temp > 20.0, target temp = 20 and boiler is heating
        // Add timestamp to collected max values and calculate average max value since last 24h
        let okToCaptureInTemp = Observable<Bool>.combineLatest(computedBoilerHeating, computedTargetTemp, resultSelector:{$0 == true && $1 == 20})
        let indoorTempToMaxTemp = Observable<Double?>
            .combineLatest(indoorTempService.temperatureObserver, okToCaptureInTemp) { (indoorTemperature:Double, authorized:Bool) -> Double? in
                return authorized == true ? indoorTemperature : nil}
            .filter{$0 != nil}
            .map{$0!}
            .scan((nil, nil)) {  (maxTemp: (new:Double?, old:Double?), indoorTemperature:Double) -> (Double?, Double?) in
                var localMaxTemp = maxTemp.new
                if indoorTemperature >= 20.0
                {
                    if localMaxTemp == nil {localMaxTemp = 0.0}
                    localMaxTemp = indoorTemperature > localMaxTemp! ? indoorTemperature : localMaxTemp!
                }
                else {localMaxTemp = nil}
                return (localMaxTemp, maxTemp.new)}
            .map({ (maxTemp: (new:Double?, old:Double?)) -> Double? in
                if maxTemp.new == nil && maxTemp.old != nil {return maxTemp.old}
                else {return nil}
            })
        
        // Regulate boiler temperature
        var timeStampDate = Date()
        
        var boilerCurrentTemperature = 75.0
        _ = boilerService.temperatureObserver
            .distinctUntilChanged()
            .debug("boilerTemperatureObserver")
            .subscribe(onNext: { (temperature:Double) in boilerCurrentTemperature = temperature})
        
        var indoorCurrentTemperature = 20.0
        _ = indoorTempService.temperatureObserver
            .subscribe(onNext: { (temperature:Double) in indoorCurrentTemperature = temperature})
        
        _ = indoorTempToMaxTemp.map({ (maxIndoorTemperature:Double?) -> Double? in
            var localMaxIndoorTemperature : Double? = maxIndoorTemperature
            if timeStampDate.timeIntervalSinceNow < -self.noPicDetectionDelayForBoilerTemperature
            {
                localMaxIndoorTemperature = indoorCurrentTemperature
                timeStampDate = Date()
            }
            
            if let localMaxIndoorTemperature = localMaxIndoorTemperature
            {
                timeStampDate = Date()
                let indoorTemperatureVsSetpointDelta = localMaxIndoorTemperature - 20.2 // 50% chauffe
                let boilerTemperatureDelta = indoorTemperatureVsSetpointDelta * 10.0 // 0.1 -> 1°  //0.5 -> 2.5°  /  0.2 -> 1°  /  0.4 -> 2°
                var resultBoilerTemperature = boilerCurrentTemperature - boilerTemperatureDelta
                if resultBoilerTemperature < 60.0 {resultBoilerTemperature = 60.0}
                if resultBoilerTemperature > 90.0 {resultBoilerTemperature = 90.0}
                return resultBoilerTemperature
            }
            else {return nil}})
            .filter{$0 != nil}.map{$0!}.debug("boilerTemperaturePublisher").subscribe(self.boilerService.temperaturePublisher)
        
        // Add timestamp to Max Temps
        var datesForMaxTemperatures = [Date: Double]()
        var totalAverage = 0
        let filteredDateForMaxTemperatureToTotalAverage = indoorTempToMaxTemp.map({ (maxTemperature:Double?) -> Int? in
            // Remove obsoletes ones in collection
            for (date,_) in datesForMaxTemperatures {
                if date.timeIntervalSinceNow < -self.boilerHeatingLevelMemorySpan {datesForMaxTemperatures.removeValue(forKey: date)}}
            if let maxTemperature = maxTemperature {
                // Add maxTemperature to timestamped collection
                datesForMaxTemperatures[Date()] = maxTemperature
                // Compute average
                let total = datesForMaxTemperatures.values.reduce(0.0, +)
                let average = total/Double(datesForMaxTemperatures.values.count)
                totalAverage = Int(round((average-20)*100/0.4))
                totalAverage = (totalAverage < 0 ? 0 : (totalAverage > 100 ? 100 : totalAverage))
            }
            if datesForMaxTemperatures.count == 0 {totalAverage = 0}
            return totalAverage
        })
        _ = filteredDateForMaxTemperatureToTotalAverage.filter{$0 != nil}.map{$0!}.distinctUntilChanged().subscribe(boilerHeatingLevelObserver)
    }
}
