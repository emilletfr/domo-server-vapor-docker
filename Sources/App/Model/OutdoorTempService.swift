//
//  OutdoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 20/09/2016.
//
//

import RxSwift


protocol OutdoorTempServicable
{
    var temperatureObserver : PublishSubject<Double> {get}
    init(httpClient:HttpClientable, repeatTimer: RepeatTimer)
}


class OutdoorTempService : OutdoorTempServicable
{
    let temperatureObserver  = PublishSubject<Double>()
    let httpClient : HttpClientable
    let autoRepeatTimer : RepeatTimer
    
    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:3600))
    {
        self.httpClient = httpClient
        self.autoRepeatTimer = repeatTimer
        repeatTimer.didFireBlock = { [weak self] in
            let url = "http://api.apixu.com/v1/current.json?key=1bd4a03d8e744bc89ff133424161712&q=damelevieres"
            guard let response = httpClient.sendGet(url), let temperature = response.parseToDoubleFrom(path:["current", "temp_c"])
                else
            {
                //self?.temperatureObserver.onError(self!);
                return
            }
            self?.temperatureObserver.onNext(temperature)
        }
    }
}
