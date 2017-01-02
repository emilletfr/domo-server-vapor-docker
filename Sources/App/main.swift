import Vapor
import HTTP
import Fluent
//import Foundation
import Dispatch
import RxSwift




let drop = Droplet()
let internalVarAccessQueue = DispatchQueue(label: "net.emillet.domo.internalVarAccessQueue")

//let mainCTrl = MainController()


    
    let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    
    _ = interval
        .subscribe(onNext: {
            print("Subscription: 1, Event: \($0)") })
    /*
     delay(5) {
     _ = interval
     .subscribe(onNext: { print("Subscription: 2, Event: \($0)") })
     }
     */


//Thread.sleep(forTimeInterval: 2.0)

//subscription.dispose()

//let sunriseSunsetController = SunriseSunsetController()
//_ = ThermostatController()
//_ = RollerShuttersController()

drop.log.enabled =  [.error, .fatal]
drop.run()
