import Vapor
import HTTP
import Fluent
import Foundation
import Dispatch
import RxSwift
import RxBlocking



let drop = Droplet()
let internalVarAccessQueue = DispatchQueue(label: "net.emillet.domo.internalVarAccessQueue")
/*
var timer: Observable<NSInteger>!
//create the timer
timer = Observable<NSInteger>.interval(0.1, scheduler: MainScheduler.instance)
timer.subscribeNext({ msecs -> Void in
print("\(msecs)00ms")
})//.addDisposableTo(bag)
 */

//let sunriseSunsetController = SunriseSunsetController()
//_ = ThermostatController()
//_ = RollerShuttersController()

drop.log.enabled =  [.error, .fatal]
drop.run()
