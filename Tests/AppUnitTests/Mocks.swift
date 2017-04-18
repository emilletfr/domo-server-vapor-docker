//
//  Mocks.swift
//  VaporApp
//
//  Created by Eric on 27/01/2017.
//
//




import RxSwift
import Vapor
//@testable import SunriseSunsetServicable

let drop = Droplet()


final class MockSunriseSunsetService : SunriseSunsetServicable
{
    let sunriseTimeObserver = PublishSubject<String>()
    let sunsetTimeObserver = PublishSubject<String>()
    
    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60*60))
    {
    }
}

final class MockRollerShutterService : RollerShutterServicable
{
    let currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let targetPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    
    let targetPositionPublisher = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    
    required init( _ httpClient : HttpClientable = HttpClient())
    {
    }
}

final class MockOutdoorTempService : OutdoorTempServicable
{
    let temperatureObserver  = PublishSubject<Double>()
    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60*60))
    {
        
    }
}

final class MockIndoorTempService : IndoorTempServicable
{
    var temperatureObserver =  PublishSubject<Double>()
    var humidityObserver = PublishSubject<Int>()
    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60*60))
    {
        
    }
}

final class MockInBedService : InBedServicable
{
    let isInBedObserver = PublishSubject<Bool>()
    
    required init(httpClient: HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60))
    {
    }
}

final class MockBoilerService : BoilerServicable
{
    var heaterPublisher = PublishSubject<Bool>()
    var pompPublisher = PublishSubject<Bool>()
    var temperaturePublisher = PublishSubject<Double>()
    
    var temperatureObserver = PublishSubject<Double>()
    required init(httpClient: HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60))
    {
    }
}
