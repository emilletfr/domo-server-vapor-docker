//
//  IndoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 26/09/2016.
//
//

import Foundation
import Dispatch
import Vapor
import HTTP


class IndoorTempService : MinuteRepeatTimer
{
    var completion : ((_ degresValue: Double?, _ humidityValue: Int?) -> Void)?
    init(completion : ((_ degresValue: Double?, _ humidityValue: Int?) -> Void)?)
    {
        self.completion = completion
        self.startMinuteRepeatTimer()
    }
    
    func minuteRepeatTimerFired()
    {
        let urlString = "http://10.0.1.10/status"
        let response = try? drop.client.get(urlString)
        guard let temperature = response?.json?["temperature"]?.double, let humidity = response?.json?["humidity"]?.double else {self.completion?(nil, nil); return}
     //   self.degresValue = temperature - 0.2 //etallonage
      //  self.humidityValue = Int(humidity)
        self.completion?(temperature - 0.2, Int(humidity))
    }

}
