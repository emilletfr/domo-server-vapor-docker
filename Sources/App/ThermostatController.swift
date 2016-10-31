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
    private let dataPath = (drop.workDir + ".build/debug/ThermostatTargetTemperature.txt")
    
    var thermostatTargetTemperature : Int
        {
        get {
            /*
             let datasourceDictionary = try? PropertyListSerialization.propertyList(from:readData, options: [], format: nil) as? [String:Double],
             let value = datasourceDictionary?["ThermostatTargetTemperature"]
             */
            guard
                let readData = try? Data(contentsOf: URL(fileURLWithPath: dataPath)),
                let readString = String(data: readData, encoding: .utf8),
                let value = Int(readString)
                else {print("error : getting thermostatTargetTemperature"); return 20}
            return value
        }
        set (newValue) {
            /*
             let datasourceDictionary = ["ThermostatTargetTemperature":"10"]
             let datasourceAny = datasourceDictionary as! AnyObject
             guard let writeData = try? PropertyListSerialization.data(fromPropertyList: datasourceAny, format: .binary, options: 0),
             */
            let newValueString = "\(newValue)"
            guard
                let writeData = newValueString.data(using: .utf8),
                let _ = try? writeData.write(to: URL(fileURLWithPath: dataPath))
                else {print("error : setting thermostatTargetTemperature"); return}
        }
    }
    /*{
     get {let value = UserDefaults.standard.double(forKey: "ThermostatTargetTemperature"); return (value < 10.0 ? 10.0 : value) }
     set (newValue) {UserDefaults.standard.set(newValue, forKey: "ThermostatTargetTemperature")}
     }*/
    
    //var thermostatMode = "auto"
    //  private var client: ClientProtocol.Type!
    //  var repeatTimer: DispatchSourceTimer?
    //var urlSession : URLSession?
    var indoorTempController : IndoorTempController!
    var outdoorTempController : OutdoorTempController!
    //  var indoorTemperature : Double = 10.0
    //   var heaterOnOrOffMemory : Bool?
    //  var pompOnOrOffMemory : Bool?
    var repeatTimerQueue : DispatchQueue?
    
    enum HeatingCoolingState: Int { case OFF = 0, HEAT, COOL, AUTO }
    var currentHeatingCoolingState = HeatingCoolingState.HEAT
    var targetHeatingCoolingState = HeatingCoolingState.HEAT
    enum TemperatureDisplayUnits: Int { case CELSIUS = 0, FAHRENHEIT }
   // let internalVarAccessQueue = DispatchQueue(label: "RollerShuttersController.Internal")
    
    init()
    {
        if FileManager.default.fileExists(atPath: self.dataPath) == false
        {
            try? FileManager.default.moveItem(at: URL(fileURLWithPath: (drop.workDir + "Public/ThermostatTargetTemperature.txt")), to: URL(fileURLWithPath:self.dataPath))
        }
        
        self.indoorTempController = IndoorTempController()
        self.outdoorTempController = OutdoorTempController()
        
        /*
         self.repeatTimer?.cancel()
         self.repeatTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue(label: "ThermostatController.RepeatTimer"))
         self.repeatTimer?.scheduleRepeating(deadline: DispatchTime.init(secondsFromNow:1), interval: DispatchTimeInterval.seconds(60))
         self.repeatTimer?.setEventHandler(handler: self.refresh)
         self.repeatTimer?.resume()
         */
        
        self.repeatTimerQueue = DispatchQueue(label: "ThermostatController.Timer")
        self.repeatTimerQueue?.async { [weak self] in
            sleep(5)
            while (true)
            {
                self?.refresh()
                sleep(60*3)
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
                if intValue == HeatingCoolingState.OFF.rawValue { self.thermostatTargetTemperature = 5 } // HORS GEL
                self.currentHeatingCoolingState = HeatingCoolingState(rawValue: intValue != HeatingCoolingState.AUTO.rawValue ? intValue : HeatingCoolingState.HEAT.rawValue)!
                self.targetHeatingCoolingState = self.currentHeatingCoolingState
                self.refresh()
            }
            return try JSON(node: ["value": value])
        }
        
        //MARK:  CurrentTemperature
        
        drop.get("thermostat/getCurrentTemperature") { request in
            var value = 0.0
            internalVarAccessQueue.sync {
                value = self.indoorTempController.degresValue
            }
            return try JSON(node: ["value": value])
        }
        
        //MARK:  TargetTemperature
        
        drop.get("thermostat/getTargetTemperature") { request in
            var value = 0
            internalVarAccessQueue.sync {
                let temperature = self.thermostatTargetTemperature < 10 ? 10 :  Int(self.thermostatTargetTemperature)
                value = temperature
            }
            return  try JSON(node: ["value": value])
        }
        
        drop.get("thermostat/setTargetTemperature", String.self) { request, value in
            internalVarAccessQueue.async {
                if self.thermostatTargetTemperature != Int(value)
                {
                    self.thermostatTargetTemperature = Int(value) ?? 10
                    self.refresh()
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
            var value = 0
            internalVarAccessQueue.sync {
                value = self.indoorTempController.humidityValue
            }
            return try JSON(node: ["value": value])
        }
        
        /*
         
         // Optional Characteristics
         
         drop.get("thermostat/getHeatingThresholdTemperature") { request in
         try JSON(node: ["value": 20])
         }
         
         drop.get("thermostat/setHeatingThresholdTemperature", Int.self) { request, value in
         try JSON(node: ["value": 20])
         }
         
         drop.get("thermostat/getCoolingThresholdTemperature") { request in
         try JSON(node: ["value": 20])
         }
         
         drop.get("thermostat/setCoolingThresholdTemperature", Int.self) { request, value in
         try JSON(node: ["value": 20])
         }
         */
        
    }
    
    func refresh()
    {
        log("ThermostatController:refresh")
        
        log("targetTemperature : \(self.thermostatTargetTemperature) - indoorTemperature : \(self.indoorTempController.degresValue)° - humidity : \(self.indoorTempController.humidityValue)% - outdoorTemperature : \(Int(self.outdoorTempController.degresValue))°")
        
        let heating = Int(self.indoorTempController.degresValue) < self.thermostatTargetTemperature
        
        if self.currentHeatingCoolingState != .OFF {self.currentHeatingCoolingState = heating ? .HEAT : .COOL}
        if self.targetHeatingCoolingState != .OFF {self.targetHeatingCoolingState = heating ? .HEAT : .COOL}
        
        DispatchQueue.global(qos:.background).async {
            self.forceHeaterOnOrOff(heaterOnOrOff: heating)
        }
        DispatchQueue.global(qos:.background).async {
            self.forcePompOnOrOff(pompOnOrOff: heating)
        }
    }
    
    func forceHeaterOnOrOff(heaterOnOrOff:Bool)
    {
        do
        {
            log("forceHeaterOnOrOff : \((heaterOnOrOff == true ? "1" : "0"))")
            let urlString = "http://10.0.1.15:8015/0" + (heaterOnOrOff == true ? "1" : "0")
            _ = try drop.client.get(urlString)
        }
        catch {log("error : unable to forceHeaterOnOrOff(\((heaterOnOrOff == true ? "1" : "0")))")}
    }
    
    func forcePompOnOrOff(pompOnOrOff:Bool)
    {
        do
        {
            log("forcePompOnOrOff : \((pompOnOrOff == true ? "1" : "0"))")
            let urlString = "http://10.0.1.15:8015/1" + (pompOnOrOff == true ? "1" : "0")
            _ = try drop.client.get(urlString)
        }
        catch {log("error : unable to forcePompOnOrOff(\((pompOnOrOff == true ? "1" : "0")))")}
    }
}
