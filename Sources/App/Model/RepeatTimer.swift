//
//  TimerRepeatable.swift
//  VaporApp
//
//  Created by Eric on 12/12/2016.
//
//

import Foundation
import Dispatch
import RxSwift


protocol RepeatTimerable
{
    static func timePublisher() -> Observable<String>
}


class RepeatTimer : RepeatTimerable
{
    var didFireBlock : (Void) -> () = {}
    let repeatSubject = BehaviorSubject<Bool>(value:true)
    
    static func timePublisher() -> Observable<String>
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
    
    init(delay:UInt32)
    {
        /*
         sleep(1)
         self.didFireBlock()
         _ = repeatSubject.asObservable().debounce(delay, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).subscribe {[weak self] event in
         print("HIT")
         defer{self?.repeatSubject.onNext(true)}
         self?.didFireBlock()
         }
         */
        DispatchQueue.global(qos:.default).async {
            usleep(10_000)
            self.didFireBlock()
            while (true) {
                sleep(delay)
                self.didFireBlock()
            }
            
        }
    }
}

/*
 let ee = BehaviorSubject<Bool>(value:true)
 _ = ee.asObservable().throttle(2, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).subscribe { event in
 defer{ee.onNext(true)}
 print(event)
 
 }
 */

/*
 protocol RepeatTimerable
 {
 var delay : UInt32 {get}
 // var didFire : (Void) -> () {get set}
 var didFireBlock : (Void) -> () {get set}
 init()
 }
 
 extension RepeatTimerable
 {
 init(delay:UInt32)
 {
 self.init()
 //  let delay = UInt32(self.delay)
 DispatchQueue.global(qos:.default).async {
 while (true)
 {
 self.didFireBlock()
 sleep(delay)
 }
 }
 }
 
 }
 */
/*
 class HourRepeatTimer : RepeatTimerable
 {
 var delay: UInt32 = 60*60
 required init() {}
 }
 
 class MinuteRepeatTimer : RepeatTimerable
 {
 var delay: UInt32 = 60
 required init() {}
 }
 
 class SecondRepeatTimer : RepeatTimerable
 {
 var delay: UInt32 = 1
 required init() {}
 }
 */
