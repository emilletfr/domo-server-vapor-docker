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
    var rollerShuttersCurrentPositions = [0,0,0,0]
    var rollerShuttersTargetPositions = [0,0,0,0]
    var rollerShuttersAreWorking = [false, false, false, false]
    
    init()
    {
        for  index in 0..<rollerShuttersCurrentPositions.count
        {
            let open = self.actionCheckIfOpen(rollerShutterIndex: index) ?? false
            self.rollerShuttersCurrentPositions[index] = open ? 100 : 0
            self.rollerShuttersTargetPositions[index] = open ? 100 : 0
        }
        
        drop.get("window-covering/getCurrentPosition", Int.self)
        { request, index in
            return try JSON(node: ["value": self.rollerShuttersCurrentPositions[index]])
        }
        
        drop.get("window-covering/getTargetPosition", Int.self)
        { request, index in
            return try JSON(node: ["value": self.rollerShuttersTargetPositions[index]])
        }
        
        drop.get("window-covering/setTargetPosition", Int.self, Int.self)
        { request, index, position in
            let currentPos = self.rollerShuttersCurrentPositions[index]
            let targetPos = self.rollerShuttersTargetPositions[index]
            let isWorking = self.rollerShuttersAreWorking[index]
            let offset = currentPos > position ? currentPos - position : position - currentPos
            if position != targetPos && isWorking == false && offset > 15
            {
                self.rollerShuttersAreWorking[index] = true
                self.rollerShuttersTargetPositions[index] = position
                self.actionOpen(rollerShutterIndex: index, position: position )
                self.rollerShuttersCurrentPositions[index] = position
                self.rollerShuttersAreWorking[index] = false
                //   self.rollerShuttersPositions[index] = self.rollerShuttersPositions[index] == 0 ? 0 : 100
                //    self.actionQueue.sync {self.actionForAllRollerShutters(openOrClose: position == 1)}
            }

            return try JSON(node: ["value": position])
        }

        drop.get("window-covering/getCurrentPosition/all")
        { request in
        //    guard let open = self.actionCheckIfOpen(rollerShutterIndex: 0) else {return "error"}
            return try JSON(node: ["value": self.rollerShuttersCurrentPositions[0]])
        }
        
        drop.get("window-covering/getTargetPosition/all")
        { request in
           // guard let open = self.actionCheckIfOpen(rollerShutterIndex: 0) else {return "error"}
          //  return try JSON(node: ["value": open == true ? 100 : 0])
            return try JSON(node: ["value": self.rollerShuttersTargetPositions[0]])
        }
        
        drop.get("window-covering/setTargetPosition/all", Int.self)
        { request, position in
   //         self.actionQueue.sync {self.actionForAllRollerShutters(openOrClose: position == 100)}
           // self.actionForAllRollerShutters(openOrClose: position == 100)
            return try JSON(node: ["value": position])
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
        guard let sunriseTime = self.sunriseSunsetController.sunriseTime , let sunsetTime = self.sunriseSunsetController.sunsetTime else {return}
        if date == "\(sunriseTime):00"
        {
            log("RollerShuttersController:actionForAllRollerShutters() - now : \(date) - sunriseTime : \(sunriseTime) - sunsetTime : \(sunsetTime)")
            self.actionForAllRollerShutters(openOrClose: true)
        }
        if date == "\(sunsetTime):00"
        {
            log("RollerShuttersController:actionForAllRollerShutters() - now : \(date) - sunriseTime : \(sunriseTime) - sunsetTime : \(sunsetTime)")
            self.actionForAllRollerShutters(openOrClose: false)
        }
    }
    
    func actionForAllRollerShutters(openOrClose:Bool)
    {
        for index in 0...3
        {
            self.actionOpen(rollerShutterIndex: index, position: openOrClose ? 100 : 0)
        }
    }
    
    func actionOpen(rollerShutterIndex:Int, position:Int)
    {
        do
        {
            let currentPos = self.rollerShuttersCurrentPositions[rollerShutterIndex]
            let targetPos = self.rollerShuttersTargetPositions[rollerShutterIndex]
            let open = targetPos > currentPos ? "1" : "0"
            let urlString = "http://10.0.1.1\(rollerShutterIndex)/\(open)"
            _ = try drop.client.get(urlString)
            let offset = currentPos > targetPos ? currentPos - targetPos : targetPos - currentPos
            var delay = 140000*(offset)
            if position == 0 || position == 100 {delay = 14_000_000}
            usleep(useconds_t(delay))
            _ = try drop.client.get(urlString)
            sleep(2)
        }
        catch {log(error)}
    }
    
    func actionCheckIfOpen(rollerShutterIndex:Int) -> Bool?
    {
        let urlString = "http://10.0.1.1\(rollerShutterIndex)/status"
        let response = try? drop.client.get(urlString)
        guard let localResponse = response, let json = localResponse.json, let openJson = json["open"], let open = openJson.int else {return nil}
        return open == 1
    }
}