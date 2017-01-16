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
import RxSwift

protocol OutdoorTempServiceable
{
    var temperatureObserver : PublishSubject<Double> {get}
    init(httpClient:HttpClientable, repeatTimer: RepeatTimer)
}

class OutdoorTempService : OutdoorTempServiceable, Error
{
    var temperatureObserver  = PublishSubject<Double>()
    var httpClient : HttpClientable!
    var autoRepeatTimer : RepeatTimer!
    
    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60*60))
    {
        self.httpClient = httpClient
        self.autoRepeatTimer = repeatTimer
        repeatTimer.didFireBlock = { [weak self] in
            let url = "http://api.apixu.com/v1/current.json?key=1bd4a03d8e744bc89ff133424161712&q=damelevieres"
            guard let response = httpClient.sendGet(url:url), let temperature = response.parseToDoubleFrom(path:["current", "temp_c"])
                else {self?.temperatureObserver.onError(self!); return}
            self?.temperatureObserver.onNext(temperature)
        }
    }
    
    /*
     
     var degres: Observable<Double> {return degresSubject.asObservable()}
     var degresSubject = PublishSubject<Double>()
     
     
     
     func repeatTimerFired()
     {
     do
     {
     let urlString = "http://api.apixu.com/v1/current.json?key=1bd4a03d8e744bc89ff133424161712&q=damelevieres"
     let response = try drop.client.get(urlString)
     guard let degres = response.data["current", "temp_c"]?.double else
     {
     //     self.completion?(nil)
     log("error getting outdoor temp from ws")
     return}
     
     self.degresSubject.onNext(degres)
     // self.completion?(degres)
     } catch {/*self.completion?(nil);*/ log(error)}
     }
     */
}

/*
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
 
 */

/*
 
 http://api.yr.no/weatherapi/locationforecast/1.9/?lat=48.55;lon=6.40", latitude, longitude]; // lat=48.55;lon=6.40"; //Blainville
 
 */
