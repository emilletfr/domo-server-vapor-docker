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


class OutdoorTempService : RepeatTimer
{
    
    var completion : ((Double?) -> Void)?

    init(completion: ((Double?) -> Void)?)
    {
        self.completion = completion
        self.startRepeatTimerWithRepeatDelay(delay: 3600)
    }
    
    func repeatTimerFired()
    {
                do
                {
                    let urlString = "http://api.apixu.com/v1/current.json?key=1bd4a03d8e744bc89ff133424161712&q=damelevieres"
                    let response = try drop.client.get(urlString)
                    guard let degres = response.data["current", "temp_c"]?.double else
                    {
                        self.completion?(nil)
                        log("error getting outdoor temp from ws")
                        return}
                    
                    log("error getting outdoor temp from ws");
                    self.completion?(degres)
                } catch {self.completion?(nil); log(error)}
        }
}

/*
 
 http://api.yr.no/weatherapi/locationforecast/1.9/?lat=48.55;lon=6.40", latitude, longitude]; // lat=48.55;lon=6.40"; //Blainville
 
 */
