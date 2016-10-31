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
    
    var thermostatTargetTemperature : Double
        {
            get {
                /*
                 let datasourceDictionary = try? PropertyListSerialization.propertyList(from:readData, options: [], format: nil) as? [String:Double],
                 let value = datasourceDictionary?["ThermostatTargetTemperature"]
                 */
                    guard
                        let readData = try? Data(contentsOf: URL(fileURLWithPath: dataPath)),
                        let readString = String(data: readData, encoding: .utf8),
                        let value = Double(readString)
                        else {print("error : getting thermostatTargetTemperature"); return 20.0}
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
            return try JSON(node: ["value": self.currentHeatingCoolingState.rawValue])
        }
        
        //MARK:  TargetHeatingCoolingState
        
        drop.get("thermostat/getTargetHeatingCoolingState") { request in
            return try JSON(node: ["value": self.targetHeatingCoolingState.rawValue])
        }
        
        drop.get("thermostat/setTargetHeatingCoolingState", String.self) { request, value in
            guard let intValue = Int(value) else {return try JSON(node: ["value": 0])}
            if intValue == HeatingCoolingState.OFF.rawValue { self.thermostatTargetTemperature = 5.0 } // HORS GEL
            self.currentHeatingCoolingState = HeatingCoolingState(rawValue: intValue != HeatingCoolingState.AUTO.rawValue ? intValue : HeatingCoolingState.HEAT.rawValue)!
            self.targetHeatingCoolingState = self.currentHeatingCoolingState
            self.refresh()
            return try JSON(node: ["value": intValue])
        }
        
        //MARK:  CurrentTemperature
        
        drop.get("thermostat/getCurrentTemperature") { request in
            try JSON(node: ["value": self.indoorTempController.degresValue])
        }
        
        //MARK:  TargetTemperature
        
        drop.get("thermostat/getTargetTemperature") { request in
            let temperature = self.thermostatTargetTemperature < 10.0 ? 10 :  Int(self.thermostatTargetTemperature)
            return  try JSON(node: ["value": temperature])
        }
        
        drop.get("thermostat/setTargetTemperature", String.self) { request, value in
            self.thermostatTargetTemperature = Double(value) ?? 10.0
            self.refresh()
            return try JSON(node: ["value": self.thermostatTargetTemperature])
        }
        
        //MARK:  TemperatureDisplayUnits
        
        drop.get("thermostat/getTemperatureDisplayUnits") { request in
            try JSON(node: ["value": TemperatureDisplayUnits.CELSIUS.rawValue])
        }
        
        drop.get("thermostat/setTemperatureDisplayUnits", Int.self) { request, value in
            try JSON(node: ["value": TemperatureDisplayUnits.CELSIUS.rawValue])
        }
        
        drop.get("humidity-sensor/getCurrentRelativeHumidity") { request in
            try JSON(node: ["value": self.indoorTempController.humidityValue])
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
        
        let heating = self.indoorTempController.degresValue < self.thermostatTargetTemperature
        
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
