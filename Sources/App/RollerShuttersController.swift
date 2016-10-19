//
//  RollerShutters.swift
//  VaporApp
//
//  Created by Eric on 18/10/2016.
//
//

import Foundation
import Dispatch
import Vapor
import HTTP

class RollerShuttersController
{
    let actionQueue = DispatchQueue(label: "RollerShuttersController.Action")
    let sunriseSunsetController = SunriseSunsetController()
    
    init()
    {
        drop.get("rollershutters", "status")
        { request in
            guard let open = self.checkIfOpen(rollerShutterIndex: 0) else {return "error"}
            return open == true ? "1" : "0"
        }

        drop.get("rollershutters", Int.self)
        { request, open in
            self.actionQueue.sync {self.actionForAllRollerShutters(openOrClose: open == 1)}
            return try JSON(node: ["open": open])
        }
        
        DispatchQueue(label: "net.emilletfr.domo.ThermostatController.TimerSeconde").async
            {
                while true
                {
                    sleep(1)
                    DispatchQueue(label: "net.emilletfr.domo.Main.TimerSeconde").async {
                        let date = Date(timeIntervalSinceNow: 0)
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = TimeZone(abbreviation: "CEST")
                        dateFormatter.locale = Locale(identifier: "fr_FR")
                        dateFormatter.dateFormat =  "HH:mm:ss"
                        self.timerSeconde(date: dateFormatter.string(from: date))
                    }
                }
        }
    }
    
    func checkIfOpen(rollerShutterIndex:Int) -> Bool?
    {
        let urlString = "http://10.0.1.1\(rollerShutterIndex)/status"
        let response = try? drop.client.get(urlString)
        guard let localResponse = response, let json = localResponse.json, let openJson = json["open"], let open = openJson.int else {return nil}
        return open == 1
    }
    
    func timerSeconde(date:String)
    {
        if let sunriseTime = self.sunriseSunsetController.sunriseTime , let sunsetTime = self.sunriseSunsetController.sunsetTime
        {
            log("now : \(date) - sunriseTime : \(sunriseTime) - sunsetTime : \(sunsetTime)")
            if date == "\(sunriseTime):00" {self.actionForAllRollerShutters(openOrClose: true)}
            if date == "\(sunsetTime):00" {self.actionForAllRollerShutters(openOrClose: false)}
        }
    }
    
    func actionForAllRollerShutters(openOrClose:Bool)
    {
        let state = openOrClose ? "1" : "0"
        do
        {
            for index in 0...3
            {
                let urlString = "http://10.0.1.1\(index)/\(state)"
                _ = try drop.client.get(urlString)
                log("RollerShuttersOpen : \(state)")
                sleep(13)
            }
        }
        catch {log(error)}
    }
}
