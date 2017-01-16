//
//  MainController.swift
//  VaporApp
//
//  Created by Eric on 02/01/2017.
//
//

//import Foundation
import RxSwift
//import RxBlocking
//import RxCocoaRuntime
//import RxCocoa

class MainController {
    
   // var rr : Observable<Int>?
    
   // Thread.sleep(forTimeInterval: 2.0)
    
   // subscription.dispose()
    
    let rr = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .subscribe(onNext: { _ in
            print("Resource count")
        })
    
    let timer = Observable<Int>.timer(0, period: 3, scheduler: MainScheduler.instance).map { _ in
        print("hh")
    }
    
    init() {
        /*
        
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        
        _ = interval
            .subscribe(onNext: { print("Subscription: 1, Event: \($0)") })
    }
    
        delay(5) {
            _ = interval
                .subscribe(onNext: { print("Subscription: 2, Event: \($0)") })
    
 
    */
    }
    

}
