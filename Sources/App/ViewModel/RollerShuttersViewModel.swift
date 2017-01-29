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
    //MARK: Dispatcher
    init(_ rollerShuttersService:RollerShutterServicable,_ inBedService:InBedServicable, _ sunriseSunsetService:SunriseSunsetServicable, _ timePublisher:Observable<String>)
}


final class RollerShuttersViewModel : RollerShuttersViewModelable
{
    //MARK: Subscriptions
    let currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let targetPositionObserver  = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    //MARK: Actions
    let targetPositionPublisher = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    //MARK: Services
    let rollerShuttersService : RollerShutterServicable
    let inBedService: InBedServicable
    let sunriseSunsetService : SunriseSunsetServicable
    let timePublisher : Observable<String>
    //MARK: Dispatcher
    required init(_ rollerShuttersService: RollerShutterServicable = RollerShutterService(), _ inBedService: InBedServicable = InBedService(), _ sunriseSunsetService : SunriseSunsetServicable = SunriseSunsetService(), _ timePublisher:Observable<String> = RepeatTimer.timePublisher().distinctUntilChanged())
    {
        self.rollerShuttersService = rollerShuttersService
        self.inBedService = inBedService
        self.sunriseSunsetService = sunriseSunsetService
        self.timePublisher = timePublisher
        self.reduce()
    }
    
    //MARK: Reducer
    func reduce()
    {
        //Group roller shutters
        let targetAllPublisher = PublishSubject<[Int]>()
        let targetAllExceptBedRoomPublisher = PublishSubject<[Int]>()
        
        //MARK: Wrap observers and targetAllPublisher
        for placeIndex in 0..<Place.count.rawValue {
            _ = self.rollerShuttersService.currentPositionObserver[placeIndex].subscribe(self.currentPositionObserver[placeIndex])
            _ = self.rollerShuttersService.targetPositionObserver[placeIndex].subscribe(self.targetPositionObserver[placeIndex])
            _ = self.targetPositionPublisher[placeIndex].subscribe(self.rollerShuttersService.targetPositionPublisher[placeIndex])
            _ = targetAllPublisher.map{$0[placeIndex]}.subscribe(rollerShuttersService.targetPositionPublisher[placeIndex])
            if placeIndex != Place.BEDROOM.rawValue {
                _ = targetAllExceptBedRoomPublisher.map{$0[placeIndex]}.subscribe(rollerShuttersService.targetPositionPublisher[placeIndex])
            }
        }
        //MARK:  Open AllRollingShutters at sunrise
        _ = Observable.combineLatest(timePublisher, sunriseSunsetService.sunriseTimeObserver.debug("sunriseTime"), resultSelector: {($0 == $1)})
            .filter{$0 == true}.map{ok in return Array(repeatElement(100, count: Place.count.rawValue - 1))}
            .debug("sunrise")
            .subscribe(targetAllExceptBedRoomPublisher)
        
        //MARK:  Close AllRollingShutters at sunset
        _ = Observable.combineLatest(timePublisher, sunriseSunsetService.sunsetTimeObserver.debug("sunsetTime"), resultSelector: {($0 == $1)})
            .filter{$0 == true}.map{ok in return Array(repeatElement(0, count: Place.count.rawValue))}
            .debug("sunset")
            .subscribe(targetAllPublisher)
        
        //MARK:  Open bedroom rollershutter after getting out of bed for 15mn
        let wakeUpSequence = [true] + Array(repeating: false, count: 15)
        _ = inBedService.isInBedObserver
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .scan([false], accumulator: { (isInBedAccu:[Bool], isInBed:Bool) -> [Bool] in
                return isInBedAccu.count >= wakeUpSequence.count ? Array(isInBedAccu.dropFirst()) + [isInBed] : isInBedAccu + [isInBed] })
            .filter{$0 == wakeUpSequence}
            .map{isInBedSequence in return 100}
            .debug("OutOfBed")
            .subscribe(self.rollerShuttersService.targetPositionPublisher[Place.BEDROOM.rawValue])
    }
}
