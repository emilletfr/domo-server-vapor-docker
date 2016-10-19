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
    var allOpened = false
    let sunriseSunsetController = SunriseSunsetController()
    
    init()
    {
        drop.get("rollershutters", "status")
        { request in
            return self.allOpened ? "1" : "0"
        }

        drop.get("rollershutters", Int.self)
        { request, open in
            self.actionQueue.sync {
                self.allOpened = open == 1
                self.action(openOrClose: open == 1)
            }
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
    
    func timerSeconde(date:String)
    {
        log("now : \(date) - sunriseTime\(self.sunriseSunsetController.sunriseTime) - sunsetTime\(self.sunriseSunsetController.sunsetTime)")
         if let sunriseTime = self.sunriseSunsetController.sunriseTime , let sunsetTime = self.sunriseSunsetController.sunsetTime
         {
         if date == "\(sunriseTime):00" {self.action(openOrClose: true)}
         if date == "\(sunsetTime):00" {self.action(openOrClose: false)}
         }
        
    }
    
    func action(openOrClose:Bool)
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
