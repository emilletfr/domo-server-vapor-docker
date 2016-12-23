//
//  inBedController.swift
//  VaporApp
//
//  Created by Eric on 28/11/2016.
//
//

import Foundation
import Dispatch
import Vapor
import HTTP

class InBedController
{
    var isInBed = false
  //  var repeatTimerQueue = DispatchQueue.global(qos: .background)
    
    init() {
    //    self.repeatTimerQueue = DispatchQueue(label: "InBedController.Timer")
        DispatchQueue.global(qos: .background).async { [weak self] in // DispatchSourceTimer : 100% cpu
            while (true)
            {
                DispatchQueue.global().async {   self?.retrieveValue() }
                sleep(10)
            }
        }
    }
    
    func retrieveValue()
    {
        do
        {
            let urlString = "http://10.0.1.24/status"
            let response = try drop.client.get(urlString)
            guard let inBed = response.json?["inBed"]?.int else
            {
                log("ERROR - InBedController:retrieveValue:guard:response: \(response)")
                self.isInBed = false
                return
            }
            self.isInBed = inBed == 1
        }
        catch {log("ERROR - InBedController:retrieveValue:catch:error: \(error)")}
    }



}
