//
//  Mocks.swift
//  VaporApp
//
//  Created by Eric on 27/01/2017.
//
//

import RxSwift

class MockOutdoorTempService : OutdoorTempServicable
{
    let temperatureObserver  = PublishSubject<Double>()
    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60*60))
    {
    }
}

class MockIndoorTempService : IndoorTempServicable
{
    var temperatureObserver =  PublishSubject<Double>()
    var humidityObserver = PublishSubject<Int>()
    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60*60))
    {
        
    }
}

class MockInBedService : InBedServicable
{
    let isInBedObserver = PublishSubject<Bool>()
    
    required init(httpClient: HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60))
    {
    }
}

class MockBoilerService : BoilerServicable
{
    internal var heaterPublisher = PublishSubject<Bool>()
    internal var pompPublisher = PublishSubject<Bool>()
    
    required init(httpClient:HttpClientable = HttpClient())
    {
    }
}
