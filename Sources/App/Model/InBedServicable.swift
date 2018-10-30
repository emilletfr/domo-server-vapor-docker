//
//  InBedService.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import RxSwift


protocol InBedServicable
{
    var isInBedObserver : PublishSubject<Bool> {get}
    init(httpClient:HttpClientable, repeatTimer: RepeatTimer)
}
