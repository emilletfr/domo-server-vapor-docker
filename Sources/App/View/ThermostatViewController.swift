//
//  ThermostatViewController.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import Vapor
//import Run

final class ThermostatViewController
{
    var viewModel : ThermostatViewModelable!
    var boilerHeatingLevel: Double = 0
    var forceHotWater: Int = 0
    var currentHeatingCoolingState = HeatingCoolingState.OFF
    var targetHeatingCoolingState = HeatingCoolingState.HEAT
    var indoorTemperature: Double = 20
    var targetTemperature: Double = 20
    enum TemperatureDisplayUnits: Int { case CELSIUS = 0, FAHRENHEIT }
    var outdoorTemperature: Double = 0
    var indoorHumidity: Double = 50
    
    func start(viewModel:ThermostatViewModelable = ThermostatViewModel())
    {
        self.viewModel = viewModel
        
        // Set Initial Values
        viewModel.targetHeatingCoolingStatePublisher.onNext(.HEAT)
        viewModel.targetTemperaturePublisher.onNext(20)
        viewModel.forcingWaterHeaterPublisher.onNext(0)
        
        // Subscribe to view model
        _ = viewModel.boilerHeatingLevelObserver.subscribe(onNext: { self.boilerHeatingLevel = $0 })
        _ = viewModel.forcingWaterHeaterObserver.subscribe(onNext: { self.forceHotWater = $0 })
        _ = viewModel.currentHeatingCoolingStateObserver.subscribe(onNext: { self.currentHeatingCoolingState = $0 })
        _ = viewModel.targetHeatingCoolingStateObserver.subscribe(onNext: { self.targetHeatingCoolingState = $0 })
        _ = viewModel.currentIndoorTemperatureObserver.subscribe(onNext: { self.indoorTemperature = $0 })
        _ = viewModel.targetIndoorTemperatureObserver.subscribe(onNext: { self.targetTemperature = $0 })
        _ = viewModel.currentOutdoorTemperatureObserver.subscribe(onNext: { self.outdoorTemperature = $0 })
        _ = viewModel.currentIndoorHumidityObserver.subscribe(onNext: { self.indoorHumidity = $0 })
    }
    
    //MARK: Boiler Heating Level
    
    func getBoilerHeatingLevelCurrentRelativeHumidity(_ req: Request) throws -> Future<ReturnDoubleValue> {
        return req.future().transform(to: ReturnDoubleValue(value: Double(self.boilerHeatingLevel)))
    }
    
    //MARK:  Force Hot Water
    
    func getForceHotWater(_ req: Request) throws -> Future<ReturnIntValue> {
        return req.future().transform(to: ReturnIntValue(value: self.forceHotWater))
    }
    
    func setForceHotWater(_ req: Request) throws -> Future<ReturnIntValue> {
        let value = try req.parameters.next(Int.self)
        defer {self.viewModel.forcingWaterHeaterPublisher.onNext(value)}
        return req.future().transform(to: ReturnIntValue(value: value))
    }
    
    //MARK:  Heating Cooling State
    
    func getThermostatCurrentHeatingCoolingState(_ req: Request) throws -> Future<ReturnIntValue> {
        return req.future().transform(to: ReturnIntValue(value: self.currentHeatingCoolingState.rawValue))
    }
    
    func getThermostatTargetHeatingCoolingState(_ req: Request) throws -> Future<ReturnIntValue> {
        return req.future().transform(to: ReturnIntValue(value: self.targetHeatingCoolingState.rawValue))
    }
    
    func setThermostatTargetHeatingCoolingState(_ req: Request) throws -> Future<ReturnIntValue> {
        let value = try req.parameters.next(Int.self)
        let state = HeatingCoolingState(rawValue:value)
        defer {viewModel.targetHeatingCoolingStatePublisher.onNext(state!)}
        return req.future().transform(to:ReturnIntValue(value: value))
    }
    
    //MARK:  Current Indoor Temperature

    func getThermostatCurrentTemperature(_ req: Request) throws -> Future<ReturnDoubleValue> {
        return req.future().transform(to: ReturnDoubleValue(value: self.indoorTemperature))
    }
    
    //MARK:  Target Indoor Temperature
    
    func getThermostatTargetTemperature(_ req: Request) throws -> Future<ReturnDoubleValue> {
        return req.future().transform(to: ReturnDoubleValue(value: self.targetTemperature))
    }
    
    func setThermostatTargetTemperature(_ req: Request) throws -> Future<ReturnDoubleValue> {
        let value = try req.parameters.next(Double.self)
        defer {viewModel.targetTemperaturePublisher.onNext(value)}
        return req.future().transform(to: ReturnDoubleValue(value: value))
    }
    
    //MARK:  Temperature Display Units
    
    func getThermostatTemperatureDisplayUnits(_ req: Request) throws -> Future<ReturnIntValue> {
        return req.future().transform(to: ReturnIntValue(value: TemperatureDisplayUnits.CELSIUS.rawValue))
    }
    
    func setThermostatTemperatureDisplayUnits(_ req: Request) throws -> Future<ReturnIntValue> {
        return req.future().transform(to: ReturnIntValue(value: TemperatureDisplayUnits.CELSIUS.rawValue))
    }
    
    //MARK:  Current Outdoor Temperature
    
    func getTemperatureSensorCurrentTemperature(_ req: Request) throws -> Future<ReturnDoubleValue> {
        return req.future().transform(to: ReturnDoubleValue(value: self.outdoorTemperature))
    }
    
    //MARK:  Indoor Humidity
    
    func getHumiditySensorCurrentRelativeHumidity(_ req: Request) throws -> Future<ReturnDoubleValue> {
        return req.future().transform(to: ReturnDoubleValue(value: self.indoorHumidity))
    }
}

