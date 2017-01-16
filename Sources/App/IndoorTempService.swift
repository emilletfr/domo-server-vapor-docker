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
    var temperatureObserver : PublishSubject<Double> {get}
    var humidityObserver : PublishSubject<Int> {get}
    init(httpClient:HttpClientable, repeatTimer: RepeatTimer)
}

final class IndoorTempService : IndoorTempServiceable, Error
{
    var temperatureObserver  = PublishSubject<Double>()
    var humidityObserver = PublishSubject<Int>()
    var httpClient : HttpClientable!
    var autoRepeatTimer : RepeatTimer!
    
    init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:20))
    {
        self.httpClient = httpClient
        self.autoRepeatTimer = repeatTimer
        repeatTimer.didFireBlock = { [weak self] in
            guard let response = httpClient.sendGet(url: "http://10.0.1.10/status"),
                let temperature = response.parseToDoubleFrom(path: ["temperature"]),
                let humidity = response.parseToIntFrom(path: ["humidity"])
            else
            {
                self?.temperatureObserver.onError(self!)
                self?.humidityObserver.onError(self!)
                return
            }
            self?.temperatureObserver.onNext(temperature)
            self?.humidityObserver.onNext(humidity)
        }
    }
}
