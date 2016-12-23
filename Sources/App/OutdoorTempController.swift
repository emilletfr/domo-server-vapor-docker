//
//  OutdoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 20/09/2016.
//
//

import Vapor
import Foundation
import Dispatch
import HTTP


class OutdoorTempController
{
    let serialQueue = DispatchQueue(label: "net.emilletfr.domo.OutdoorTempManager.Internal")
    private var internalDegresValue : Double = 20.0
    var degresValue : Double {
        get {return serialQueue.sync { internalDegresValue }}
        set (newValue) {serialQueue.sync { internalDegresValue = newValue}}
    }
    private var client: ClientProtocol.Type!

    
    init()
    {
        
        DispatchQueue.global(qos: .background).async { [weak self] in // DispatchSourceTimer : 100% cpu
            while (true)
            {
                DispatchQueue.global().async {self?.retrieveTemp()}
                sleep(3600)
            }
        }
        /*
        DispatchQueue(label: "net.emilletfr.domo.OutdoorTempManager.Timer").async
            {
                while true
                {
                    self.retrieveTemp()
                    sleep(3600)
                }
        }
 */
        
        drop.get("temperature-sensor/getCurrentTemperature") { request in
          //  guard let degresValue = self.degresValue else { let res = try Response(status: .badRequest, json:  JSON(node:[])); return res}
          return try JSON(node: ["value": self.degresValue])
        }
    }
    
    private func retrieveTemp()
    {
                do
                {
                   let urlString = "http://api.apixu.com/v1/current.json?key=1bd4a03d8e744bc89ff133424161712&q=damelevieres"
                    let response = try drop.client.get(urlString)
                     guard let degres = response.data["current", "temp_c"]?.double else
                     {
                        log("ERROR - OutdoorTempController:retrieveTemp:guard:response: \(response)")
                        return
                    }
                    self.degresValue = degres
                } catch {log("ERROR - OutdoorTempController:retrieveTemp:catch:error: \(error)")}
    }
}

