import Vapor
//import HTTP
//import Fluent
//import Foundation
import Dispatch
import RxSwift


    



let drop = Droplet()


let internalVarAccessQueue = DispatchQueue(label: "net.emillet.domo.internalVarAccessQueue")



/*
DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(30)) {
    print("asyncAfter finished")
    for i in 1...1000 {print("M")}
}
 */
DispatchQueue.global(qos: .userInitiated).async{
    print("asyncAfter finished")
    for i in 1...20 {print("D")}
}
DispatchQueue.global(qos: .userInitiated).async{
    print("asyncAfter finished")
    for i in 1...20 {print("D2")}
}
print("MainThread")
 for i in 1...20 {print("M")}

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


