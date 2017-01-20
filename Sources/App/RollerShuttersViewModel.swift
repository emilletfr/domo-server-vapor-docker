//
//  RollerShuttersViewModel.swift
//  VaporApp
//
//  Created by Eric on 20/12/2016.
//
//

import Foundation
import RxSwift
import Dispatch


protocol RollerShuttersViewModelable
{
    //MARK: Subscriptions
    var currentPositionObserver : [PublishSubject<Int>] {get}
    var currentAllPositionObserver : PublishSubject<Int> {get}
    var targetPositionObserver : [PublishSubject<Int>] {get}
    var targetAllPositionObserver : PublishSubject<Int> {get}
    //MARK: Actions
    var targetPositionPublisher : [PublishSubject<Int>] {get}
    var targetAllPositionPublisher : PublishSubject<Int> {get}
    
    init(_ rollerShuttersService:RollerShutterServicable,_ inBedService:InBedServicable, _ sunriseSunsetService : SunriseSunsetServicable)
}


final class RollerShuttersViewModel : RollerShuttersViewModelable
{
    static let shared = RollerShuttersViewModel()
    //MARK: Subscriptions
    let currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(),PublishSubject<Int>()]
    let currentAllPositionObserver = PublishSubject<Int>()
    let targetPositionObserver  = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(),PublishSubject<Int>()]
    let targetAllPositionObserver = PublishSubject<Int>()
    //MARK: Actions
    let targetPositionPublisher  = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(),PublishSubject<Int>()]
    let targetAllPositionPublisher = PublishSubject<Int>()
    //MARK: Services
    let rollerShuttersService : RollerShutterServicable
    let inBedService: InBedServicable
    let sunriseSunsetService : SunriseSunsetServicable
    
    required init(_ rollerShuttersService: RollerShutterServicable = RollerShutterService(), _ inBedService: InBedServicable = InBedService(), _ sunriseSunsetService : SunriseSunsetServicable = SunriseSunsetService())
    {
        self.rollerShuttersService = rollerShuttersService
        self.inBedService = inBedService
        self.sunriseSunsetService = sunriseSunsetService
        self.reduce()
    }
    
    //MARK: Reducer
    func reduce()
    {
        // Open bedroom rollershutter after getting out of bed for 15mn
        let wakeUpSequence = [true] + Array(repeating: false, count: 15)
        _ = inBedService.isInBedObserver.throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .scan([false], accumulator: { (isInBedAccu:[Bool], isInBed:Bool) -> [Bool] in
                return isInBedAccu.count >= wakeUpSequence.count ? Array(isInBedAccu.dropFirst()) + [isInBed] : isInBedAccu + [isInBed] })
            .filter({$0 == wakeUpSequence}).map{a in return 100}
            .subscribe(self.rollerShuttersService.targetPositionPublisher[Place.BEDROOM.rawValue])
        
        // Open AllRollingShutters at sunrise
        _ = Observable.combineLatest(self.timePublisher(), sunriseSunsetService.sunriseTimeObserver, resultSelector: {($0 == $1)})
            .filter{$0 == true}.map{ok in return 100}
            .subscribe(self.rollerShuttersService.targetAllPositionPublisher)
        
        // Close AllRollingShutters at sunset
        _ = Observable.combineLatest(self.timePublisher(), sunriseSunsetService.sunsetTimeObserver, resultSelector: {($0 == $1)})
            .filter{$0 == true}.map{ok in return 0}
            .subscribe(self.rollerShuttersService.targetAllPositionPublisher)
        
        // Multiple Rolling Shutter command
        _ = self.targetAllPositionPublisher.subscribe(self.rollerShuttersService.targetAllPositionPublisher)
        _ = self.rollerShuttersService.currentAllPositionObserver.subscribe(self.currentAllPositionObserver)
        _ = self.rollerShuttersService.targetAllPositionObserver.subscribe(self.targetAllPositionObserver)
        
        // Single Rolling Shutter command
        for placeIndex in 0..<Place.count.rawValue
        {
            _ = self.rollerShuttersService.currentPositionObserver[placeIndex].subscribe(self.currentPositionObserver[placeIndex])
            _ = self.rollerShuttersService.targetPositionObserver[placeIndex].subscribe(self.targetPositionObserver[placeIndex])
            _ = self.targetPositionPublisher[placeIndex].subscribe(self.rollerShuttersService.targetPositionPublisher[placeIndex])
        }
    }
    
    func timePublisher() -> Observable<String>
    {
        return PublishSubject<String>.create { (obs:AnyObserver<String>) -> Disposable in
            DispatchQueue.global().async {
                while true {
                    let date = Date(timeIntervalSinceNow: 0)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(abbreviation: "CEST")
                    dateFormatter.locale = Locale(identifier: "fr_FR")
                    dateFormatter.dateFormat =  "HH:mm"
                    obs.onNext(dateFormatter.string(from: date))
                    sleep(55)
                }
            }
            return Disposables.create()
        }
    }
}





