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

class InBedService : MinuteRepeatTimer
{
    var completion : ((Bool?) -> Void)!
    
    init(completion : @escaping (Bool?) -> Void)
    {
        self.startMinuteRepeatTimer()
        self.completion = completion
    }

    func minuteRepeatTimerFired()
    {
        let response = try? drop.client.get("http://10.0.1.24/status")
        guard let inBed = response?.json?["inBed"]?.int else {self.completion(nil); return}
        self.completion(inBed == 1)
    }
}

extension InBedService
{
    

}
