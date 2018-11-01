//
//  BoilerService.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import RxSwift

protocol BoilerServicable
{
    var heaterPublisher : PublishSubject<Bool> {get}
    var pompPublisher : PublishSubject<Bool> {get}
    var temperaturePublisher : PublishSubject<Double> {get}
    
    var temperatureObserver : PublishSubject<Double> {get}
    
    init(httpClient: HttpClientable, refreshPeriod: Int)
}
