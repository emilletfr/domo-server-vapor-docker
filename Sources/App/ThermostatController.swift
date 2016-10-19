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
    private let dataUrl = URL(fileURLWithPath: (drop.workDir + "Public/Settings.plist"))
    
    var thermostatTargetTemperature : Double
        {
            get {
                var returnValue : Double = 5.0
                    guard
                        let readData = try? Data(contentsOf: dataUrl), let readString = String(data: readData, encoding: .utf8), let value = Double(readString)
                        /*
                        let datasourceDictionary = try? PropertyListSerialization.propertyList(from:readData, options: [], format: nil) as? [String:Double],
                        let value = datasourceDictionary?["ThermostatTargetTemperature"]
 */
                        else {print("error : getting thermostatTargetTemperature"); return returnValue}
                        returnValue = value
 
                return returnValue
             }
            set (newValue) {

           //         let datasourceDictionary = ["ThermostatTargetTemperature":"10"]
             //   let datasourceAny = datasourceDictionary as! AnyObject
           //     guard let writeData = try? PropertyListSerialization.data(fromPropertyList: datasourceAny, format: .binary, options: 0),
                let newValueString = "\(newValue)"
                guard
                    let writeData = newValueString.data(using: .utf8),
                    let _ = try? writeData.write(to: dataUrl)
                    else {print("error : setting thermostatTargetTemperature"); return}
            }
    }
    /*{
     get {let value = UserDefaults.standard.double(forKey: "ThermostatTargetTemperature"); return (value < 10.0 ? 10.0 : value) }
     set (newValue) {UserDefaults.standard.set(newValue, forKey: "ThermostatTargetTemperature")}
     }*/
    
    var thermostatMode = "auto"
    //  private var client: ClientProtocol.Type!
    //  var repeatTimer: DispatchSourceTimer?
    //var urlSession : URLSession?
    var indoorTempController : IndoorTempController!
    var outdoorTempController : OutdoorTempController!
    //  var indoorTemperature : Double = 10.0
    //   var heaterOnOrOffMemory : Bool?
    //  var pompOnOrOffMemory : Bool?
    var repeatTimerQueue : DispatchQueue?
    
    
    init()
    {
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
                sleep(60)
            }
        }
        
        drop.get("thermostat/status") {  request in
            return try JSON(node: [
                "targetTemperature":self.thermostatTargetTemperature < 10.0 ? 10.0 :  self.thermostatTargetTemperature,
                "temperature": self.indoorTempController.degresValue < 10.0 ? 10.0 :  self.indoorTempController.degresValue,
                "humidity": self.indoorTempController.humidityValue,
                "thermostat": self.thermostatMode
                ])
        }
        
        drop.get("thermostat/targetTemperature", String.self) { request, temperatureString in
            log("targetTemperature : \(temperatureString)")
            let temperature = Double(temperatureString) ?? 10.0
            self.thermostatTargetTemperature = temperature <= 10.0 ? 5.0 : temperature
            self.refresh()
            return temperatureString
        }
        
        drop.get("thermostat", String.self) { request, mode in
            log(mode) // off / comfort / comfort-minus-two / auto
            self.thermostatMode = mode
            return self.thermostatMode
        }
    }
    
    func refresh()
    {
        log("ThermostatController:refresh")

        log("targetTemperature : \(self.thermostatTargetTemperature) - indoorTemperature : \(self.indoorTempController.degresValue)° - humidity : \(self.indoorTempController.humidityValue)% - outdoorTemperature : \(Int(self.outdoorTempController.degresValue))°")
        DispatchQueue.global(qos:.background).async {
            self.forceHeaterOnOrOff(heaterOnOrOff: self.indoorTempController.degresValue < self.thermostatTargetTemperature)
        }
        DispatchQueue.global(qos:.background).async {
            self.forcePompOnOrOff(pompOnOrOff: self.indoorTempController.degresValue < self.thermostatTargetTemperature)
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
