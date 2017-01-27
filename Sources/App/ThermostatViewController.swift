//
//  ThermostatViewController.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import Vapor


final class ThermostatViewController
{
    let thermostatViewModel : ThermostatViewModelable
    
    init(viewModel:ThermostatViewModelable = ThermostatViewModel())
    {
        self.thermostatViewModel = viewModel
        
        // Set Initial Values
        
        viewModel.targetHeatingCoolingStatePublisher.onNext(.HEAT)
        viewModel.targetTemperaturePublisher.onNext(20)
        viewModel.forcingWaterHeaterPublisher.onNext(0)
        
        //MARK: Boiler Heating Level
        
        var boilerHeatingLevel = 0
        _ = viewModel.boilerHeatingLevelObserver.subscribe(onNext: { boilerHeatingLevel = $0 })
        drop.get("boiler-heating-level/getCurrentRelativeHumidity") { request in
            return  try JSON(node: ["value": boilerHeatingLevel])}
        
        //MARK:  Force Hot Water
        
        var forceHotWater = 0
        _ = viewModel.forcingWaterHeaterObserver.subscribe(onNext: { forceHotWater = $0 })
        drop.get("force-hot-water/getOn") { request in
            return  try JSON(node: ["value": forceHotWater])}
        
        drop.get("force-hot-water/setOn", Int.self) { request, value in
            viewModel.forcingWaterHeaterPublisher.onNext(value)
            return try JSON(node: ["value": value])}
        
        //MARK:  Current Heating Cooling State
        
         var currentHeatingCoolingState = HeatingCoolingState.OFF
        _ = viewModel.currentHeatingCoolingStateObserver.subscribe(onNext: { currentHeatingCoolingState = $0 })
        drop.get("thermostat/getCurrentHeatingCoolingState") { request in return try JSON(node: ["value": currentHeatingCoolingState.rawValue])}
        
        //MARK:  Target Heating Cooling State
        
        var targetHeatingCoolingState = HeatingCoolingState.HEAT
        _ = viewModel.targetHeatingCoolingStateObserver.subscribe(onNext: { targetHeatingCoolingState = $0 })
        drop.get("thermostat/getTargetHeatingCoolingState") { request in
            return try JSON(node: ["value": targetHeatingCoolingState.rawValue])}
        
        drop.get("thermostat/setTargetHeatingCoolingState", String.self) { request, value in
            if let intValue = Int(value), let state = HeatingCoolingState(rawValue:intValue) {viewModel.targetHeatingCoolingStatePublisher.onNext(state)}
             return try JSON(node: ["value": value])}
        
        //MARK:  Current Indoor Temperature
        
        var indoorTemperature = 20
        _ = viewModel.currentIndoorTemperatureObserver.subscribe(onNext: { indoorTemperature = $0 })
        drop.get("thermostat/getCurrentTemperature") { request in
            return try JSON(node: ["value": indoorTemperature])}
        
        //MARK:  Target Indoor Temperature
        
        var targetTemperature = 20
        _ = viewModel.targetIndoorTemperatureObserver.subscribe(onNext: { targetTemperature = $0 })
        drop.get("thermostat/getTargetTemperature") { request in
            return  try JSON(node: ["value": targetTemperature])}
        
        drop.get("thermostat/setTargetTemperature", String.self) { request, value in
            if let intValue = Int(value) {viewModel.targetTemperaturePublisher.onNext(intValue)}
            return try JSON(node: ["value": value])}
        
        //MARK:  Current Outdoor Temperature
        
        var outdoorTemperature = 0
        _ = viewModel.currentOutdoorTemperatureObserver.subscribe(onNext: { outdoorTemperature = $0 })
        drop.get("temperature-sensor/getCurrentTemperature") { request in
            return try JSON(node: ["value": outdoorTemperature])}
        
        //MARK:  Temperature Display Units
        
        enum TemperatureDisplayUnits: Int { case CELSIUS = 0, FAHRENHEIT }
        
        drop.get("thermostat/getTemperatureDisplayUnits") { request in
            try JSON(node: ["value": TemperatureDisplayUnits.CELSIUS.rawValue])}
        
        drop.get("thermostat/setTemperatureDisplayUnits", Int.self) { request, value in
            try JSON(node: ["value": TemperatureDisplayUnits.CELSIUS.rawValue])}
        
        //MARK:  Indoor Humidity
        
        var indoorHumidity = 50
        _ = viewModel.currentIndoorHumidityObserver.subscribe(onNext: { indoorHumidity = $0 })
        drop.get("humidity-sensor/getCurrentRelativeHumidity") { request in
            return try JSON(node: ["value": indoorHumidity])
        }
    }
}

