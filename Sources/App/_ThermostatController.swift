//
//  ThermostatController.swift
//  VaporApp
//
//  Created by Eric on 17/10/2016.
//
//


import Foundation
import Dispatch
import Vapor
import HTTP

class ThermostatController
{
  //  var dataStore = DataModelStore.shared
    
    private let dataPath = (drop.workDir + ".build/debug/ThermostatTargetTemperature.txt")
    var thermostatTargetTemperature : Int = 20
    var computedThermostatTargetTemperature : Int = 20
    var repeatTimerQueue : DispatchQueue?

    
    enum HeatingCoolingState: Int { case OFF = 0, HEAT, COOL, AUTO }
    var currentHeatingCoolingState = HeatingCoolingState.HEAT
    var targetHeatingCoolingState = HeatingCoolingState.HEAT
    enum TemperatureDisplayUnits: Int { case CELSIUS = 0, FAHRENHEIT }
   // let internalVarAccessQueue = DispatchQueue(label: "RollerShuttersController.Internal")
    

    
    init()
    {        
        self.repeatTimerQueue = DispatchQueue(label: "ThermostatController.Timer")
        self.repeatTimerQueue?.async { [weak self] in
            sleep(5)
            while (true)
            {
                self?.refresh()
                sleep(60) //60*2
            }
        }
        
        // Required Characteristics
        
        //MARK:  CurrentHeatingCoolingState
        
        drop.get("thermostat/getCurrentHeatingCoolingState") { request in
            var value = 0
            internalVarAccessQueue.sync {
                value = self.currentHeatingCoolingState.rawValue
            }
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
                value = self.targetHeatingCoolingState.rawValue
            }
            return try JSON(node: ["value": value])
        }
        
        drop.get("thermostat/setTargetHeatingCoolingState", String.self) { request, value in
            guard let intValue = Int(value) else {return try JSON(node: ["value": 0])}
            internalVarAccessQueue.async {
         //       if intValue == HeatingCoolingState.OFF.rawValue { self.computedThermostatTargetTemperature = 7 } // HORS GEL
          //      if intValue == HeatingCoolingState.AUTO.rawValue { self.computedThermostatTargetTemperature = self.thermostatTargetTemperature }
                self.currentHeatingCoolingState = HeatingCoolingState(rawValue: intValue != HeatingCoolingState.AUTO.rawValue ? intValue : HeatingCoolingState.HEAT.rawValue)!
                self.targetHeatingCoolingState = self.currentHeatingCoolingState
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
                let temperature = (self.computedThermostatTargetTemperature) < 10 ? 10 :  Int(self.computedThermostatTargetTemperature)
                value = temperature
            }
            return  try JSON(node: ["value": value])
        }
        
        drop.get("thermostat/setTargetTemperature", String.self) { request, value in
            internalVarAccessQueue.async {
                if self.thermostatTargetTemperature != Int(value)
                {
                    self.thermostatTargetTemperature = Int(value) ?? 10
                  //  self.refresh()
                }
            }
            return try JSON(node: ["value": value])
        }
        
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
    
    func refresh()
    {
        /*
    //    self.inBedOffsetTemperature = inBedController.isInBed ? -2 : 0;
        if self.currentHeatingCoolingState == .OFF {self.computedThermostatTargetTemperature = 5}
        else
        {
            self.computedThermostatTargetTemperature = self.thermostatTargetTemperature + (dataStore.data.isInBed ? -2 : 0)
        }
        let heating = self.dataStore.data.indoorTemperature < Double(self.computedThermostatTargetTemperature)
        if self.currentHeatingCoolingState != .OFF {self.currentHeatingCoolingState = heating ? .HEAT : .COOL}
        if self.targetHeatingCoolingState != .OFF {self.targetHeatingCoolingState = heating ? .HEAT : .COOL}
        /*
        var logString = ""
        logString += "trgtTemp: \(self.thermostatTargetTemperature)"
        logString += ", computTrgtTemp: \(self.computedThermostatTargetTemperature)"
        logString += ", inBed: \((dataStore.data.isInBed == true ? "1" : "0"))"
        logString += ", inTemp: \(self.indoorTempController.degresValue)"
        logString += ", humid: \(self.indoorTempController.humidityValue)%"
        logString += ", outTemp: \(Int(self.dataStore.outdoor.degresValue))"
        logString += ", heaterOn: \((heating == true ? "1" : "0"))"
        logString += ", pompOn: \((heating == true ? "1" : "0"))"
        logString += ", snrise: \(sunriseSunsetController.sunriseTime ?? "nil")"
        logString += ", snset: \(sunriseSunsetController.sunsetTime ?? "nil")"
        log(logString)
        */
        DispatchQueue.global(qos:.background).async {self.forceHeaterOnOrOff(heaterOnOrOff: heating)}
        DispatchQueue.global(qos:.background).async {self.forcePompOnOrOff(pompOnOrOff: heating)}
 */
    }
    
    func forceHeaterOnOrOff(heaterOnOrOff:Bool)
    {
        do
        {
            let urlString = "http://10.0.1.15:8015/0" + (heaterOnOrOff == true ? "1" : "0")
            _ = try drop.client.get(urlString)
        }
        catch {log("error : unable to forceHeaterOnOrOff(\((heaterOnOrOff == true ? "1" : "0")))")}
    }
    
    func forcePompOnOrOff(pompOnOrOff:Bool)
    {
        do
        {
            let urlString = "http://10.0.1.15:8015/1" + (pompOnOrOff == true ? "1" : "0")
            _ = try drop.client.get(urlString)
        }
        catch {log("error : unable to forcePompOnOrOff(\((pompOnOrOff == true ? "1" : "0")))")}
    }
}
