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
    
    init(rollerShuttersServices:[RollerShutterService], inBedService:InBedService)
}

class RollerShuttersViewModel : RollerShuttersViewModelable
{
        //MARK: Subscriptions
    var currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(),PublishSubject<Int>()]
    var currentAllPositionObserver = PublishSubject<Int>()
    var targetPositionObserver  = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(),PublishSubject<Int>()]
    var targetAllPositionObserver = PublishSubject<Int>()
        //MARK: Actions
    var targetPositionPublisher  = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(),PublishSubject<Int>()]
    var targetAllPositionPublisher = PublishSubject<Int>()
        //MARK: Services
    let rollerShuttersServices : [RollerShutterService]
    let inBedService: InBedService
    
    required init(rollerShuttersServices: [RollerShutterService] = [RollerShutterService(.LIVING_ROOM), RollerShutterService(.DINING_ROOM) ,RollerShutterService(.OFFICE) ,RollerShutterService(.KITCHEN), RollerShutterService(.BEDROOM)] , inBedService: InBedService = InBedService())
    {
        self.rollerShuttersServices = rollerShuttersServices
        self.inBedService = inBedService
        self.reduce()
     }
    
    //MARK: Reducer
    func reduce()
    {
        var wakeUpSequence = [Bool?](); for _ in 0...20 {wakeUpSequence += [true]}; for _ in 0...20 {wakeUpSequence += [false]}
        _ = inBedService.isInBedObserver.throttle(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).scan(0, accumulator: { (index:Int, value:Bool) -> Int in
            if index < wakeUpSequence.count && (wakeUpSequence[index] == value || ( index > 8 && index < 12 ))  {return index + 1}
            return 0
        }).subscribe(onNext: { (value:Int) in
            log("wakeup : \(value == wakeUpSequence.count)")
        })

    }
}





