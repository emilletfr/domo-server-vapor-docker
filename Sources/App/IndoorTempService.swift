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

typealias Callback = ((Void) -> Void)

protocol IndoorTempServiceable
{
    
    var degres : Double? {get}
    var humidity : Int? {get}
    func subscribe(degresDidChange:@escaping Callback, humidityDidChange:@escaping Callback)
}

final class IndoorTempService<T:HttpToJsonClientable> : MinuteRepeatTimer, IndoorTempServiceable
{
    
    private var degresDidChangeForRegisteredOnes = [Callback]()
    private var humidityDidChangeForRegisteredOnes = [Callback]()
    var degres : Double? {didSet{if oldValue != degres {for r in degresDidChangeForRegisteredOnes {r()}}}}
    var humidity : Int? { didSet {if oldValue != humidity  {for r in humidityDidChangeForRegisteredOnes {r()}}}}
    var httpToJsonClient : T!
    var subscribedIndex = 0
    
    func subscribe(degresDidChange: @escaping Callback, humidityDidChange: @escaping Callback)
    {
        degresDidChangeForRegisteredOnes += degresDidChange
        humidityDidChangeForRegisteredOnes += humidityDidChange
        subscribedIndex += 1
    }
    
    init()
    {
  //      httpToJsonClient = T()
    }
    /*
    init(httpToJsonClient:HttpToJsonClientable = HttpToJsonClient())
    {
        self.httpToJsonClient = httpToJsonClient
        self.startMinuteRepeatTimer()
    }
 */
    
    func minuteRepeatTimerFired()
    {
        let itemsResp = self.httpToJsonClient.fetch(url: "http://10.0.1.10/status", jsonPaths: "temperature", "humidity")
        guard let items = itemsResp, let degres = Double(items[0]), let humidity = Double(items[1]) else {return}
        self.degres = degres - 0.2
        self.humidity = Int(humidity)
    }
}
