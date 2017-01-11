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
    var degres : Observable<Double> {get}
    var humidity : Observable<Int> {get}
    init(httpToJsonClient:HttpToJsonClientable, repeatTimer: RepeatTimer)
}


final class IndoorTempService : IndoorTempServiceable, Error
{
    var degres : Observable<Double> {return degresSubject.asObservable()}
    var humidity : Observable<Int> {return humiditySubject.asObservable()}
    var degresSubject  = PublishSubject<Double>()
    var humiditySubject = PublishSubject<Int>()
    var httpToJsonClient : HttpToJsonClientable!
    var autoRepeatTimer : RepeatTimer!
    
    init(httpToJsonClient:HttpToJsonClientable = HttpToJsonClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60))
    {
        self.httpToJsonClient = httpToJsonClient
        self.autoRepeatTimer = repeatTimer
        repeatTimer.didFireBlock = { [weak self] in
            let itemsResp = self?.httpToJsonClient.fetch(url: "http://10.0.1.10/status", jsonPaths: "temperature", "humidity")
            guard let items = itemsResp, let degres = Double(items[0]), let humidity = Double(items[1]) else
            { self?.humiditySubject.onError(self!); self?.degresSubject.onError(self!); return}
            self?.degresSubject.onNext(degres - 0.2)
            self?.humiditySubject.onNext(Int(humidity))
        }
    }
}
