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
    //var urlSession : URLSession?
    var indoorTempController : IndoorTempController!
  //  var indoorTemperature : Double = 10.0
    var heaterOnOrOffMemory = -1
    var pompOnOrOffMemory = -1
    
    init(droplet:Droplet)
    {
        print("ThermostatController:init")
        self.client = droplet.client
        self.indoorTempController = IndoorTempController(droplet: droplet)
        
      //  self.indoorTempController?.retrieveTemp()
        
        self.repeatTimer?.cancel()
        self.repeatTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue(label: "ThermostatController.RepeatTimer"))
        self.repeatTimer?.scheduleRepeating(deadline: DispatchTime.init(secondsFromNow:1), interval: DispatchTimeInterval.seconds(60))
        self.repeatTimer?.setEventHandler(handler: self.refresh)
        self.repeatTimer?.resume()
        
        droplet.get("thermostat/status") { request in
            return try JSON(node: [
                "targetTemperature":self.thermostatTargetTemperature,
                "temperature": self.indoorTempController.degresValue ,
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
   //     DispatchQueue(label: "REFRESH").sync {
 
        print("refresh")
            print("indoorTemperature:\(self.indoorTempController.degresValue)")
        DispatchQueue.global(qos:.background).async {
            self.forceHeaterOnOrOff(heaterOnOrOff: self.indoorTempController.degresValue < self.thermostatTargetTemperature)
        }
        DispatchQueue.global(qos:.background).async {
            self.forcePompOnOrOff(pompOnOrOff: self.indoorTempController.degresValue < self.thermostatTargetTemperature)
        }
 //       }
   
    }
    
    func forceHeaterOnOrOff(heaterOnOrOff:Bool)
    {
        let heaterOnOrOffMemoryLocal = heaterOnOrOff == true ? 1 : 0
        if self.heaterOnOrOffMemory == -1 || heaterOnOrOffMemoryLocal != heaterOnOrOffMemory
        {
            self.heaterOnOrOffMemory = heaterOnOrOffMemoryLocal
        print("forceHeaterOnOrOff:\((self.heaterOnOrOffMemory))")
        let urlString = "http://10.0.1.15:8015/0" + (String( self.heaterOnOrOffMemory))
        _ = try? self.client.get(urlString)
        }
       // print(response)
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
        let pompOnOrOffMemoryLocal = pompOnOrOff == true ? 1 : 0
        if self.pompOnOrOffMemory == -1 || pompOnOrOffMemoryLocal != pompOnOrOffMemory
        {
            self.pompOnOrOffMemory = pompOnOrOffMemoryLocal
        print("forcePompOnOrOff:\((self.heaterOnOrOffMemory))")
        let urlString = "http://10.0.1.15:8015/1" + (String(self.pompOnOrOffMemory))
        _ = try? self.client.get(urlString)
        }
      //  print(response)
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
