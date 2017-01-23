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
    var targetPositionObserver : [PublishSubject<Int>] {get}
    //MARK: Actions
    var targetPositionPublisher : [PublishSubject<Int>] {get}
    
    init(_ rollerShuttersService:RollerShutterServicable,_ inBedService:InBedServicable, _ sunriseSunsetService : SunriseSunsetServicable)
}


final class RollerShuttersViewModel : RollerShuttersViewModelable
{
    //MARK: Subscriptions
    let currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let currentAllPositionObserver = PublishSubject<Int>()
    let targetPositionObserver  = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let targetAllPositionObserver = PublishSubject<Int>()
    //MARK: Actions
    let targetPositionPublisher = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
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
        _ = inBedService.isInBedObserver
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .scan([false], accumulator: { (isInBedAccu:[Bool], isInBed:Bool) -> [Bool] in
                return isInBedAccu.count >= wakeUpSequence.count ? Array(isInBedAccu.dropFirst()) + [isInBed] : isInBedAccu + [isInBed] })
            .filter({$0 == wakeUpSequence}).map{a in return 100}
            .debug("OutOfBed")
            .subscribe(self.rollerShuttersService.targetPositionPublisher[Place.BEDROOM.rawValue])
        
        //Command All roller shutters
        let targetAllPublisher = PublishSubject<[Int]>()
        
        //Wrap observers and targetAllPublisher
        for placeIndex in 0..<Place.count.rawValue
        {
            _ = targetAllPublisher.map{$0[placeIndex]}.subscribe(rollerShuttersService.targetPositionPublisher[placeIndex])
            _ = self.rollerShuttersService.currentPositionObserver[placeIndex].subscribe(self.currentPositionObserver[placeIndex])
            _ = self.rollerShuttersService.targetPositionObserver[placeIndex].subscribe(self.targetPositionObserver[placeIndex])
            _ = self.targetPositionPublisher[placeIndex].subscribe(self.rollerShuttersService.targetPositionPublisher[placeIndex])
        }
        
        // Open AllRollingShutters at sunrise
        _ = Observable.combineLatest(self.timePublisher(), sunriseSunsetService.sunriseTimeObserver.debug("sunriseTime"), resultSelector: {($0 == $1)})
            .filter{$0 == true}.map{ok in return Array(repeatElement(100, count: Place.count.rawValue)).dropLast() + [0]}
            .debug("sunrise")
            .subscribe(targetAllPublisher)
        
        // Close AllRollingShutters at sunset
        _ = Observable.combineLatest(self.timePublisher(), sunriseSunsetService.sunsetTimeObserver.debug("sunsetTime"), resultSelector: {($0 == $1)})
            .filter{$0 == true}.map{ok in return Array(repeatElement(0, count: Place.count.rawValue))}
            .debug("sunset")
            .subscribe(targetAllPublisher)
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
