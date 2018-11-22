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
    let secondPublisher: PublishSubject<Int>
    
    //MARK: Dispatcher
    required init(rollerShuttersService: RollerShutterServicable = RollerShutterService(), inBedService: InBedServicable = InBedService(), sunriseSunsetService: SunriseSunsetServicable = SunriseSunsetService(), secondEmitter: PublishSubject<Int> = secondEmitter)
    {
        self.rollerShuttersService = rollerShuttersService
        self.inBedService = inBedService
        self.sunriseSunsetService = sunriseSunsetService
        self.secondPublisher = secondEmitter
        self.reduce()
    }
    
    //MARK: Reducer
    func reduce()
    {
        _ = secondPublisher.map({ _ -> String in
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
        _ = Observable.combineLatest(hourMinutePublisher, sunriseSunsetService.sunriseTimeObserver.debug("sunriseTime"), manualAutomaticModePublisher, inBedService.isInBedObserver, resultSelector:
            {(($0 == $1) && ($2 == 0), $3)})
            .filter{$0.0 == true}
            .map{$0.1}
            .debug("sunrise")
            .subscribe(onNext: { isInBed in
                for placeIndex in 0..<RollerShutter.count.rawValue {
                    if placeIndex != RollerShutter.bedroom.rawValue || (placeIndex == RollerShutter.bedroom.rawValue && !isInBed) {
                        self.rollerShuttersService.targetPositionPublisher[placeIndex].onNext(100)
                    }
                }
            })
        
        //MARK:  Close AllRollingShutters at sunset if automatic mode
        _ = Observable.combineLatest(hourMinutePublisher, sunriseSunsetService.sunsetTimeObserver.debug("sunsetTime"), manualAutomaticModePublisher, resultSelector:
            {($0 == $1) && $2 == 0})
            .filter{$0 == true}
            .debug("sunset")
            .subscribe(onNext: { _ in
                for placeIndex in 0..<RollerShutter.count.rawValue {
                    self.rollerShuttersService.targetPositionPublisher[placeIndex].onNext(0)
                }
            })
        
        //MARK: check if it is daylight or nighttime
        var isDaylight = false
        _ = Observable.combineLatest(hourMinutePublisher, sunriseSunsetService.sunriseTimeObserver, sunriseSunsetService.sunsetTimeObserver, resultSelector:{ now, sunrise, sunset in
            let stringToInt : (String) -> Int = { Int($0.replacingOccurrences(of: ":", with: ""))! }
            return stringToInt(now) > stringToInt(sunrise) && stringToInt(now) < stringToInt(sunset)
        }).subscribe(onNext: { isDayOrNight in
            isDaylight = isDayOrNight
        })
        
        //MARK:  Open bedroom rollershutter after getting out of bed for 15mn if daylight
        let wakeUpSequence = [true] + Array(repeating: false, count: 15)
        _ = inBedService.isInBedObserver
            .throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .scan([false], accumulator: { (isInBedAccu:[Bool], isInBed:Bool) -> [Bool] in
                return isInBedAccu.count >= wakeUpSequence.count ? Array(isInBedAccu.dropFirst()) + [isInBed] : isInBedAccu + [isInBed] })
            .filter{$0 == wakeUpSequence}
            .map{isInBedSequence in return 100}
            .filter({ _ in return isDaylight})
            .debug("OutOfBed")
            .subscribe(self.rollerShuttersService.targetPositionPublisher[RollerShutter.bedroom.rawValue])
        
    }
}
