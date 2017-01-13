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
    var indoorTemperature : Observable<Int> {get}
    var targetTemperature : Observable<Int> {get}
    
    init(indoorTempService:IndoorTempServiceable, inBedService:InBedServicable)
}

class ThermostatViewModel : ThermostatViewModelable
{
    var targetTemperature: Observable<Int> {return targetTemperatureSubject.asObservable()}
    var targetTemperatureSubject = PublishSubject<Int>()
    var indoorTemperature: Observable<Int> {return indoorTemperatureSubject.asObservable()}
    var indoorTemperatureSubject = PublishSubject<Int>()
    
    
    var indoorTempService : IndoorTempServiceable!
    var inBedService : InBedServicable!
    var servicesLatestObserver:Disposable
    
    required init(indoorTempService:IndoorTempServiceable = IndoorTempService(), inBedService:InBedServicable = InBedService())
    {
        self.indoorTempService = indoorTempService
        self.inBedService = inBedService
        self.servicesLatestObserver = Observable.combineLatest(indoorTempService.degres, inBedService.isInBed) { (degres, isInBed) in
            return (degres, isInBed)}.distinctUntilChanged({ (degres:Double, isInbed:Bool) in return "\(degres)\(isInbed)"
            }).debounce(10, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).subscribe(onNext: { (degres:Double, isInBed:Bool) in
                print(degres); print(isInBed)
            })
        
        
    }
    
}
