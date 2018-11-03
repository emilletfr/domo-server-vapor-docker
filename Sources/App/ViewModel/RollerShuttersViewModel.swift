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

final class RollerShuttersViewModel : RollerShuttersViewModelable
{
    //MARK: Subscriptions
    let currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let targetPositionObserver  = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let manualAutomaticModeObserver = PublishSubject<Int>()
    //MARK: Actions
    let targetPositionPublisher = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let manualAutomaticModePublisher = PublishSubject<Int>()
    //MARK: Services
    let rollerShuttersService : RollerShutterServicable
    let inBedService: InBedServicable
    let sunriseSunsetService : SunriseSunsetServicable
    let hourMinutePublisher = PublishSubject<String>()
 
    //MARK: Dispatcher
    required init(rollerShuttersService: RollerShutterServicable = RollerShutterService(), inBedService: InBedServicable = InBedService(), sunriseSunsetService: SunriseSunsetServicable = SunriseSunsetService())
    {
        self.rollerShuttersService = rollerShuttersService
        self.inBedService = inBedService
        self.sunriseSunsetService = sunriseSunsetService
        self.reduce()
    }
    
    //MARK: Reducer
    func reduce()
    {
        _ = secondEmitter.map({ _ -> String in
            let date = Date(timeIntervalSinceNow: 0)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "CEST")
            dateFormatter.locale = Locale(identifier: "fr_FR")
            dateFormatter.dateFormat =  "HH:mm"
            return dateFormatter.string(from: date)
        })
            .distinctUntilChanged()
            .subscribe(hourMinutePublisher)
        
         //MARK: Wrap Manual/Automatic Mode
        _ = self.manualAutomaticModePublisher.subscribe(manualAutomaticModeObserver)
        
        //MARK: Wrap observers and targetAllPublisher
        for placeIndex in 0..<RollerShutter.count.rawValue {
            _ = self.rollerShuttersService.currentPositionObserver[placeIndex].subscribe(self.currentPositionObserver[placeIndex])
            _ = self.rollerShuttersService.targetPositionObserver[placeIndex].subscribe(self.targetPositionObserver[placeIndex])
            _ = self.targetPositionPublisher[placeIndex].subscribe(self.rollerShuttersService.targetPositionPublisher[placeIndex])
        }
        //MARK:  Open AllRollingShutters at sunrise if automatic mode
        _ = Observable.combineLatest(hourMinutePublisher, sunriseSunsetService.sunriseTimeObserver.debug("sunriseTime"), manualAutomaticModePublisher, resultSelector:
            // {($0 == $1) && $2 == 0})
            {$0.hasSuffix("5") && $2 == 0})
            .filter{$0 == true}
            .debug("sunrise")
            .subscribe(onNext: { _ in
                for placeIndex in 0..<RollerShutter.count.rawValue {
            //         if placeIndex != RollerShutter.bedroom.rawValue {
                    self.rollerShuttersService.targetPositionPublisher[placeIndex].onNext(100)
             //       }
                }
            })
        
        //MARK:  Close AllRollingShutters at sunset if automatic mode
        _ = Observable.combineLatest(hourMinutePublisher, sunriseSunsetService.sunsetTimeObserver.debug("sunsetTime"), manualAutomaticModePublisher, resultSelector:
           // {($0 == $1) && $2 == 0})
             {$0.hasSuffix("0") && $2 == 0})
            .filter{$0 == true}
            .debug("sunset")
            .subscribe(onNext: { _ in
                for placeIndex in 0..<RollerShutter.count.rawValue {
                    self.rollerShuttersService.targetPositionPublisher[placeIndex].onNext(0)
                }
        })
        
        //MARK:  Open bedroom rollershutter after getting out of bed for 15mn
        let wakeUpSequence = [true] + Array(repeating: false, count: 15)
        _ = inBedService.isInBedObserver
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .scan([false], accumulator: { (isInBedAccu:[Bool], isInBed:Bool) -> [Bool] in
                return isInBedAccu.count >= wakeUpSequence.count ? Array(isInBedAccu.dropFirst()) + [isInBed] : isInBedAccu + [isInBed] })
            .filter{$0 == wakeUpSequence}
            .map{isInBedSequence in return 100}
            .debug("OutOfBed")
            .subscribe(self.rollerShuttersService.targetPositionPublisher[RollerShutter.bedroom.rawValue])
    }
}
