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


class OutdoorTempController// : NSObject
{
    let serialQueue = DispatchQueue(label: "net.emilletfr.domo.OutdoorTempManager.Internal")
    private var internalDegresValue : Double?
    var degresValue : Double? {
        get {return serialQueue.sync { internalDegresValue }}
        set (newValue) {serialQueue.sync { internalDegresValue = newValue}}
    }
    private var client: ClientProtocol.Type

    
    init(droplet:Droplet)
    {
        self.client = droplet.client
        DispatchQueue(label: "net.emilletfr.domo.OutdoorTempManager.Timer").async
            {
                while true
                {
                    self.retrieveTemp()
                    sleep(3600)
                }
        }
        
        droplet.get("outdoorTemp") { request in
            guard let degresValue = self.degresValue else { let res = try Response(status: .badRequest, json:  JSON(node:[])); return res}
            return String(describing: degresValue)
        }
    }
    
    private func retrieveTemp()
    {
        DispatchQueue(label: "queuename1", attributes: .concurrent).async
            {
                do
                {
                    let urlString = "http://api.openweathermap.org/data/2.5/weather?zip=54360,fr&APPID=9c44d7610c061d8c3a7873c51da2e885&units=metric"
                    let response = try self.client.get(urlString)
                    self.degresValue = response.data["main", "temp"]?.double ?? nil
                    if let temp = self.degresValue {Log.shared.printString(string: "outdoorTemp : \(temp)")}
                } catch {
                    Log.shared.printString(string: String(describing: error))
                }
        }
    }
}

