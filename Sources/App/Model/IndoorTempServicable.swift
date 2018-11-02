//
//  IndoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 26/09/2016.
//
//

import RxSwift

protocol IndoorTempServicable
{
    var temperatureObserver : PublishSubject<Double> {get}
    var humidityObserver : PublishSubject<Int> {get}
    init(httpClient:HttpClientable, refreshPeriod: Int)
}
