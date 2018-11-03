//
//  OutdoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 20/09/2016.
//
//

import RxSwift

protocol OutdoorTempServicable
{
    var temperatureObserver : PublishSubject<Double> {get}
    init(httpClient:HttpClientable, refreshPeriod: Int)
}
