//
//  InBedService.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import RxSwift

class InBedService : InBedServicable
{
    let isInBedObserver = PublishSubject<Bool>()
    
    required init(httpClient: HttpClientable = HttpClient(), refreshPeriod: Int = 60) {
        _ = Observable.merge(secondEmitter, Observable.of(0))
            .filter { $0%refreshPeriod == 0 }
            .flatMap { _ in return httpClient.send(url: InBed.baseUrl(appendPath: "status"), responseType: InBed.Response.self) }
            .map {$0.inBed == 1}
            .subscribe(isInBedObserver)
    }
}

struct InBed {
    static func baseUrl(appendPath pathComponent: String = "") -> String {
        let scheme = "http://"
        let base = isHomeKitModulesNetworkIpOrDns
            ? "10.0.1.24" : "bed-occupancy"
        return scheme + base + "/" + pathComponent
    }
    
    struct Response: Decodable {
        let inBed: Int
        let pressionThreshold: Int
        let currentPression: Int
    }
}
