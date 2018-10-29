//
//  BoilerService.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import RxSwift
import Foundation
import Dispatch


protocol BoilerServicable
{
    var heaterPublisher : PublishSubject<Bool> {get}
    var pompPublisher : PublishSubject<Bool> {get}
    var temperaturePublisher : PublishSubject<Double> {get}
    
    var temperatureObserver : PublishSubject<Double> {get}
    
    init(httpClient:HttpClientable, repeatTimer: RepeatTimer)
}


class BoilerService : BoilerServicable, Error
{
    internal var temperaturePublisher = PublishSubject<Double>()
    internal var heaterPublisher = PublishSubject<Bool>()
    internal var pompPublisher = PublishSubject<Bool>()
    
    internal var temperatureObserver = PublishSubject<Double>()

    let httpClient : HttpClientable
    let repeatTimer : RepeatTimer
    
    let actionSerialQueue = DispatchQueue(label: "net.emillet.domo.BoilerService")
    var retryDelay = 0

    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60))
    {
        self.repeatTimer = repeatTimer
        self.httpClient = httpClient
        
        _ = heaterPublisher.subscribe(onNext: { (onOff:Bool) in
            self.retryDelay = 0
            self.activate(heaterOrPomp:true, onOff)
        })
        _ = pompPublisher.subscribe(onNext: { (onOff:Bool) in
            self.retryDelay = 0
            self.activate(heaterOrPomp:false, onOff)
        })
        
        repeatTimer.didFireBlock = { [weak self] ()->() in
            let url = "http://10.0.1.25/getTemperature"
            guard let response = httpClient.sendGet(url), let temperature = response.parseToIntFrom(path: ["value"])
                else {return}
            self?.temperatureObserver.onNext(Double(temperature))
        }
        
        _ = temperaturePublisher.subscribe(onNext: { (temperature:Double) in
            DispatchQueue.global().async {
                let url = "http://10.0.1.25/setTemperature?value=" + String(Int(temperature))
                _ = self.httpClient.sendGet(url)
            }
        })
    }
    
    
    func activate(heaterOrPomp:Bool, _ onOff:Bool)
    {
        DispatchQueue.global().async {
                self.actionSerialQueue.sync {
                        sleep(UInt32(self.retryDelay))
                        let url = "http://10.0.1.15:8015/" + (heaterOrPomp == false ? "1" : "0")  + (onOff == true ? "1" : "0")
                        if let response = self.httpClient.sendGet(url), let _ = response.parseToJSONFrom(path:["status"]) {/*print(status)*/}
                        else {
                            self.retryDelay += 1
                            self.activate(heaterOrPomp: heaterOrPomp, onOff)
                        }
                }
        }
    }
}
