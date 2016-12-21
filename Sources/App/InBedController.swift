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
    var repeatTimerQueue = DispatchQueue.global(qos: .background)
    
    init() {
    //    self.repeatTimerQueue = DispatchQueue(label: "InBedController.Timer")
        self.repeatTimerQueue.async { [weak self] in // DispatchSourceTimer : 100% cpu
            while (true)
            {
          //      self.retrieveValue()
                log("func retrieveValue()")
                DispatchQueue.global().async {
                    let urlString = "http://10.0.1.24/status"
                    let response = try? drop.client.get(urlString)
                    log("response:\(response)")
                    guard let inBed = response?.json?["inBed"]?.int else {self?.isInBed = false; log("return"); return}
                    log("self.isInBed: \(inBed == 1)")
                    self?.isInBed = inBed == 1
                }
                sleep(10)
            }
        }
    }
    
    func retrieveValue()
    {   log("func retrieveValue()")
        




    }

}