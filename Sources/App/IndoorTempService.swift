//
//  IndoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 26/09/2016.
//
//

//import Foundation
import Dispatch
import Vapor
import HTTP
import RxSwift


protocol IndoorTempServiceable
{
    var degresObserver : PublishSubject<Double> {get}
    var humidityObserver : PublishSubject<Int> {get}
    init(httpToJsonClient:HttpToJsonClientable, repeatTimer: RepeatTimer)
}

final class IndoorTempService : IndoorTempServiceable, Error
{
    var degresObserver  = PublishSubject<Double>()
    var humidityObserver = PublishSubject<Int>()
    var httpToJsonClient : HttpToJsonClientable!
    var autoRepeatTimer : RepeatTimer!
    
    init(httpToJsonClient:HttpToJsonClientable = HttpToJsonClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:20))
    {
        self.httpToJsonClient = httpToJsonClient
        self.autoRepeatTimer = repeatTimer
        repeatTimer.didFireBlock = { [weak self] in
            let itemsResp = self?.httpToJsonClient.fetch(url: "http://10.0.1.10/status", jsonPaths: "temperature", "humidity")
            guard let items = itemsResp, let degres = Double(items[0]), let humidity = Double(items[1]) else
            { self?.humidityObserver.onError(self!); self?.degresObserver.onError(self!); return}
            self?.degresObserver.onNext(degres - 0.2)
            self?.humidityObserver.onNext(Int(humidity))
        }
    }
}
