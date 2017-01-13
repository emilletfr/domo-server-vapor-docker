//
//  ThermostatViewController.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import Foundation
import Vapor

class ThermostatViewController
{
    var thermostatViewModel : ThermostatViewModelable!
    
    init(thermostatViewModel:ThermostatViewModelable = ThermostatViewModel())
    {
        self.thermostatViewModel = thermostatViewModel
        // Required Characteristics
        
        //MARK:  CurrentHeatingCoolingState
        
        drop.get("thermostat/getCurrentHeatingCoolingState") { request in
            var value = 0
       //     internalVarAccessQueue.sync {
          //      value = self.currentHeatingCoolingState.rawValue
          //  }
            return try JSON(node: ["value": value])
        }
        
        drop.get("thermostat/setCurrentHeatingCoolingState", Int.self) { request, value in
            internalVarAccessQueue.sync {}
            return try JSON(node: ["value": value])
        }
        
        //MARK:  TargetHeatingCoolingState
        
        drop.get("thermostat/getTargetHeatingCoolingState") { request in
            var value = 0
            internalVarAccessQueue.sync {
            //    value = self.targetHeatingCoolingState.rawValue
            }
            return try JSON(node: ["value": value])
        }
        
        drop.get("thermostat/setTargetHeatingCoolingState", String.self) { request, value in
            guard let intValue = Int(value) else {return try JSON(node: ["value": 0])}
            internalVarAccessQueue.async {
            //    self.currentHeatingCoolingState = HeatingCoolingState(rawValue: intValue != HeatingCoolingState.AUTO.rawValue ? intValue : HeatingCoolingState.HEAT.rawValue)!
         //       self.targetHeatingCoolingState = self.currentHeatingCoolingState
                //    self.refresh()
            }
            return try JSON(node: ["value": value])
        }
        
        //MARK:  CurrentTemperature
        
        drop.get("thermostat/getCurrentTemperature") { request in
            let value = 0.0
            internalVarAccessQueue.sync {
                //    value = self.indoorTempController.degresValue
                //           value = self.dataStore.data.indoorTemperature
            }
            return try JSON(node: ["value": value])
        }
        
        drop.get("thermostat/setCurrentTemperature", Int.self) { request, value in
            internalVarAccessQueue.sync {}
            return try JSON(node: ["value": value])
        }
        
        //MARK:  TargetTemperature
        
        drop.get("thermostat/getTargetTemperature") { request in
            var value = 0
            internalVarAccessQueue.sync {
          //      let temperature = (self.computedThermostatTargetTemperature) < 10 ? 10 :  Int(self.computedThermostatTargetTemperature)
        //        value = temperature
            }
            return  try JSON(node: ["value": value])
        }
        
        drop.get("thermostat/setTargetTemperature", String.self) { request, value in
            /*
            internalVarAccessQueue.async {
                
                if self.thermostatTargetTemperature != Int(value)
                {
                    self.thermostatTargetTemperature = Int(value) ?? 10
                    //  self.refresh()
                }
            }
 */
            return try JSON(node: ["value": value])
        }
        
        enum TemperatureDisplayUnits: Int { case CELSIUS = 0, FAHRENHEIT }
        
        //MARK:  TemperatureDisplayUnits
        
        drop.get("thermostat/getTemperatureDisplayUnits") { request in
            try JSON(node: ["value": TemperatureDisplayUnits.CELSIUS.rawValue])
        }
        
        drop.get("thermostat/setTemperatureDisplayUnits", Int.self) { request, value in
            try JSON(node: ["value": TemperatureDisplayUnits.CELSIUS.rawValue])
        }
        
        drop.get("humidity-sensor/getCurrentRelativeHumidity") { request in
            let value = 0
            internalVarAccessQueue.sync {
                //      value = self.indoorTempController.humidityValue
                //             value = self.dataStore.data.indoorHumidity
            }
            return try JSON(node: ["value": value])
        }
        
        drop.get("humidity-sensor/setCurrentRelativeHumidity", Int.self) { request, value in
            internalVarAccessQueue.sync {}
            return try JSON(node: ["value": value])
        }
    }

    }

