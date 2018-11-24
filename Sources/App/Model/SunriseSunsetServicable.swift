//
//  SunriseSunsetManager.swift
//  VaporApp
//
//  Created by Eric on 25/09/2016.
//
//

import Foundation
import Dispatch
import RxSwift

protocol SunriseSunsetServicable
{
    var sunriseTimeObserver : ReplaySubject<String> {get}
    var sunsetTimeObserver : ReplaySubject<String> {get}
    init(httpClient:HttpClientable, refreshPeriod: Int)
}

