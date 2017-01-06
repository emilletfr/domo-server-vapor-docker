import Vapor
//import HTTP
//import Fluent
//import Foundation
import Dispatch
import RxSwift


    



let drop = Droplet()


let internalVarAccessQueue = DispatchQueue(label: "net.emillet.domo.internalVarAccessQueue")




DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(30)) {
    print("finished")
}

/*
//let interval = Observable<Int>.interval(1, scheduler: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
_ = interval.subscribe(onNext: {
    print("Subscription: 1, Event: \($0)")
})

    }
 */

//Thread.sleep(forTimeInterval: 2.0)

//subscription.dispose()

//let sunriseSunsetController = SunriseSunsetController()
//_ = ThermostatController()
//_ = RollerShuttersController()

//drop.log.enabled =  [.error, .fatal]
drop.run()


