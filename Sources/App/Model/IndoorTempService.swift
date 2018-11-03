//
//  IndoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 26/09/2016.
//
//

import Dispatch
import RxSwift


final class IndoorTempService : IndoorTempServicable
{
    let temperatureObserver  = PublishSubject<Double>()
    let humidityObserver = PublishSubject<Int>()
    let httpClient : HttpClientable
    
    init(httpClient:HttpClientable = HttpClient(), refreshPeriod: Int = 60) {
        self.httpClient = httpClient
        _ = Observable.merge(secondEmitter, Observable.of(0))
            .filter { $0%refreshPeriod == 0 }
            .flatMap { _ in return httpClient.send(url: IndoorTemp.baseUrl(appendPath: "status") , responseType: IndoorTemp.Response.self) }
            .subscribe(onNext: { [weak self] (indoorTempResponse) in
                self?.temperatureObserver.onNext(indoorTempResponse.temperature - 0.2)
                self?.humidityObserver.onNext(Int(indoorTempResponse.humidity))
            })
    }
}

struct IndoorTemp {
    static func baseUrl(appendPath pathComponent: String = "") -> String {
        return RollerShutter.livingRoom.baseUrl(appendPath: pathComponent)
    }
    
    struct Response: Decodable //{ "open": 1, "temperature": 21.00, "humidity": 63.10}
    {
        let open: Int
        let temperature: Double
        let humidity: Double
    }
}
