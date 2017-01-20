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
        
        //MARK:  Current Heating Cooling State
        
         var currentHeatingCoolingState = HeatingCoolingState.OFF
        _ = viewModel.currentHeatingCoolingStateObserver.subscribe(onNext: { currentHeatingCoolingState = $0})
        drop.get("thermostat/getCurrentHeatingCoolingState") { request in return try JSON(node: ["value": currentHeatingCoolingState.rawValue])}
        
        /*
         drop.get("thermostat/setCurrentHeatingCoolingState", Int.self) { request, value in
         if let state = HeatingCoolingState(rawValue: value) {_ = viewModel.targetHeatingCoolingStatePublisher.onNext(state)}
         return try JSON(node: ["value": value])}
         */
        
        //MARK:  Target Heating Cooling State
        
        var targetHeatingCoolingState = HeatingCoolingState.HEAT
        _ = viewModel.targetHeatingCoolingStateObserver.subscribe(onNext: { targetHeatingCoolingState = $0 })
        drop.get("thermostat/getTargetHeatingCoolingState") { request in
            return try JSON(node: ["value": targetHeatingCoolingState.rawValue])
        }
        
        drop.get("thermostat/setTargetHeatingCoolingState", String.self) { request, value in
            if let intValue = Int(value), let state = HeatingCoolingState(rawValue:intValue) {viewModel.targetHeatingCoolingStatePublisher.onNext(state)}
             return try JSON(node: ["value": value])
        }
        
        //MARK:  Current Indoor Temperature
        
        var indoorTemperature = 20
        _ = viewModel.currentIndoorTemperatureObserver.subscribe(onNext: { indoorTemperature = $0 })
        drop.get("thermostat/getCurrentTemperature") { request in
            return try JSON(node: ["value": indoorTemperature])
        }
        
        /*
        drop.get("thermostat/setCurrentTemperature", Int.self) { request, value in
            return try JSON(node: ["value": value])
        }
 */
        
        //MARK:  Target Indoor Temperature
        var targetTemperature = 20
        _ = viewModel.targetIndoorTemperatureObserver.subscribe(onNext: { targetTemperature = $0 })
        drop.get("thermostat/getTargetTemperature") { request in
            return  try JSON(node: ["value": targetTemperature])
        }
        
        drop.get("thermostat/setTargetTemperature", String.self) { request, value in
            if let intValue = Int(value) {viewModel.targetTemperaturePublisher.onNext(intValue)}
            return try JSON(node: ["value": value])
        }
        
        //MARK:  Current Outdoor Temperature
        
        var outdoorTemperature = 0
        _ = viewModel.currentOutdoorTemperatureObserver.subscribe(onNext: { outdoorTemperature = $0 })
        drop.get("temperature-sensor/getCurrentTemperature") { request in
            return try JSON(node: ["value": outdoorTemperature])
        }
        
        //MARK:  Temperature Display Units
        
        enum TemperatureDisplayUnits: Int { case CELSIUS = 0, FAHRENHEIT }
        
        drop.get("thermostat/getTemperatureDisplayUnits") { request in
            try JSON(node: ["value": TemperatureDisplayUnits.CELSIUS.rawValue])
        }
        
        drop.get("thermostat/setTemperatureDisplayUnits", Int.self) { request, value in
            try JSON(node: ["value": TemperatureDisplayUnits.CELSIUS.rawValue])
        }
        
        //MARK:  Indoor Humidity
        
        var indoorHumidity = 50
        _ = viewModel.currentIndoorHumidityObserver.subscribe(onNext: { indoorHumidity = $0 })
        drop.get("humidity-sensor/getCurrentRelativeHumidity") { request in
            return try JSON(node: ["value": indoorHumidity])
        }
        /*
        drop.get("humidity-sensor/setCurrentRelativeHumidity", Int.self) { request, value in
            return try JSON(node: ["value": value])
        }
 */
    }
}

