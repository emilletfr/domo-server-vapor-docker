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
    var thermostatTargetTemperature : Double = 10.0
    var thermostatMode = "auto"
    private var client: ClientProtocol.Type
    var repeatTimer: DispatchSourceTimer?
    var urlSession : URLSession?
    var indoorTempController : IndoorTempController?
    var indoorTemperature : Double = 10.0
    
    init(droplet:Droplet)
    {
        print("ThermostatController:init")
        self.client = droplet.client
        self.indoorTempController = IndoorTempController(droplet: droplet)
        
      //  self.indoorTempController?.retrieveTemp()
        
        self.repeatTimer?.cancel()
        self.repeatTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue(label: "ThermostatController.RepeatTimer"))
        self.repeatTimer?.scheduleRepeating(deadline: DispatchTime.init(secondsFromNow:1), interval: DispatchTimeInterval.seconds(10))
        self.repeatTimer?.setEventHandler(handler: self.refresh)
        self.repeatTimer?.resume()
        
        droplet.get("thermostat/status") { request in
            return try JSON(node: [
                "targetTemperature":self.thermostatTargetTemperature,
                "temperature": self.indoorTemperature ,
                "humidity":"0",
                "thermostat": self.thermostatMode
                ])
         }
        
        droplet.get("thermostat/targetTemperature", String.self) { request, temperature in
            print(temperature)
            self.thermostatTargetTemperature = Double(temperature) ?? 10.0
            self.refresh()
            return temperature
        }
        
        droplet.get("thermostat", String.self) { request, mode in
            print(mode) // off / comfort / comfort-minus-two / auto
            self.thermostatMode = mode
           // self.refresh()
            return self.thermostatMode
        }
    }
    
    func refresh()
    {
        print("refresh")
     //   self.indoorTempController?.retrieveTemp(completion: { (indoorTemperature :Double) in
            print("indoorTemperature:\(indoorTemperature)")
       //     self.indoorTemperature = indoorTemperature
            self.forceHeaterOnOrOff(heaterOnOrOff: (indoorTempController?.degresValue)! < self.thermostatTargetTemperature)
            self.forcePompOnOrOff(pompOnOrOff: (indoorTempController?.degresValue)! < self.thermostatTargetTemperature)
     //   })
    }
    
    func forceHeaterOnOrOff(heaterOnOrOff:Bool)
    {
        print("forceHeaterOnOrOff:\((heaterOnOrOff ? "1" : "0"))")
        let urlString = "http://78.240.101.103:8015/0" + (heaterOnOrOff ? "1" : "0")
        let response = try? self.client.get(urlString)
        print(response)
        /*
        let sessionConfiguration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration:sessionConfiguration)
        self.urlSession?.dataTask(with: URL(string:urlString)!) { (data:Data?, response:URLResponse?, error:Error?) in
        
            guard
            let dataResp = data,
                let dataString = String(data: dataResp, encoding: .utf8) else {return}
            print(dataString)
        }
 */
    }
    
    
    func forcePompOnOrOff(pompOnOrOff:Bool)
    {
        print("forcePompOnOrOff:\((pompOnOrOff ? "1" : "0"))")
        let urlString = "http://78.240.101.103:8015/1" + (pompOnOrOff ? "1" : "0")
        let response = try? self.client.get(urlString)
        print(response)
        /*
        let sessionConfiguration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration:sessionConfiguration)
        self.urlSession?.dataTask(with: URL(string:urlString)!) { (data:Data?, response:URLResponse?, error:Error?) in
            guard
                let dataResp = data,
                let dataString = String(data: dataResp, encoding: .utf8) else {return}
            print(dataString)
        
        }
 */
    }

    
    
}
