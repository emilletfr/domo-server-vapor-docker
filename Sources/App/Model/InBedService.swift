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
            .flatMap { _ in return httpClient.send(url: "http://10.0.1.24/status", responseType: InBedResponse.self) }
            .map {$0.inBed == 1}
            .subscribe(isInBedObserver)
    }
    
    struct InBedResponse: Decodable {
        let inBed: Int
        let pressionThreshold: Int
        let currentPression: Int
    }
}
