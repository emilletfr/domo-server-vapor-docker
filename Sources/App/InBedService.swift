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
    var isInBed : Observable<Bool> {get}
    init(httpToJsonClient:HttpToJsonClientable, repeatTimer: RepeatTimer)
}

class InBedService : InBedServicable, Error
{
    var isInBed: Observable<Bool> {return isInBedSubject.asObservable()}
    var isInBedSubject = PublishSubject<Bool>()
    var httpToJsonClient : HttpToJsonClientable!
    var repeatTimer : RepeatTimer!
    
    required init(httpToJsonClient: HttpToJsonClientable = HttpToJsonClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60))
    {
        self.httpToJsonClient = httpToJsonClient
        self.repeatTimer = repeatTimer
        repeatTimer.didFireBlock = { [weak self] in
            let items = httpToJsonClient.fetch(url: "http://10.0.1.24/status", jsonPaths: "inBed")
            guard let item = items?[0] else {self?.isInBedSubject.onError(self!); return}
            self?.isInBedSubject.onNext(Int(item) == 1)
        }
    }
}
