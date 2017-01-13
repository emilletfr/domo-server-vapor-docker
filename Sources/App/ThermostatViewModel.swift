//
//  ThermostatViewModel.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import Foundation
import RxSwift
import Dispatch

protocol ThermostatViewModelable
{
    var targetTemperatureObserver : PublishSubject<Int> {get}
    var indoorTemperatureObserver : PublishSubject<Int> {get}
    
    init(indoorTempService:IndoorTempServiceable, inBedService:InBedServicable)
}

class ThermostatViewModel : ThermostatViewModelable
{
    var targetTemperatureObserver = PublishSubject<Int>()
    var indoorTemperatureObserver = PublishSubject<Int>()
    
    
    var indoorTempService : IndoorTempServiceable!
    var inBedService : InBedServicable!
    var servicesLatestObserver:Disposable
    
    required init(indoorTempService:IndoorTempServiceable = IndoorTempService(), inBedService:InBedServicable = InBedService())
    {
        self.indoorTempService = indoorTempService
        self.inBedService = inBedService
        self.servicesLatestObserver = Observable.combineLatest(indoorTempService.degres, inBedService.isInBed) { (degres, isInBed) in
            return (degres, isInBed)}.distinctUntilChanged({ (degres:Double, isInbed:Bool) in return "\(degres)\(isInbed)"
            }).throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).subscribe(onNext: { (degres:Double, isInBed:Bool) in
                print(degres); print(isInBed)
            })
        
        _ = Observable.combineLatest(indoorTempService.degres, inBedService.isInBed) { (degres, isInBed) in
            return (degres, isInBed)}.distinctUntilChanged({ (degres:Double, isInbed:Bool) in return "\(degres)\(isInbed)"
            }).subscribe({ event in
                print("B:\(event)")
            })
        
            _ = Observable.combineLatest(indoorTempService.degres, inBedService.isInBed) { (degres, isInBed) in
                return (degres, isInBed)}.subscribe({ event in
                    print("A:\(event)")
                })
        
        
    }
    
}
