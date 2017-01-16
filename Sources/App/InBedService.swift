//
//  InBedService.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import Dispatch
import Vapor
import HTTP
import RxSwift

protocol InBedServicable
{
    var isInBedObserver : PublishSubject<Bool> {get}
    init(httpClient:HttpClientable, repeatTimer: RepeatTimer)
}

class InBedService : InBedServicable, Error
{
    var isInBedObserver = PublishSubject<Bool>()
    var httpClient : HttpClientable!
    var repeatTimer : RepeatTimer!
    
    required init(httpClient: HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60))
    {
        self.httpClient = httpClient
        self.repeatTimer = repeatTimer
        repeatTimer.didFireBlock = { [weak self] in
            let url = "http://10.0.1.24/status"
            guard let response = httpClient.sendGet(url:url), let isInBed = response.parseToIntFrom(path: ["inBed"])
                else {self?.isInBedObserver.onError(self!); return}
            self?.isInBedObserver.onNext(Int(isInBed) == 1)
        }
    }
}
