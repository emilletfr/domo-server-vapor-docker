import Vapor
import HTTP
import Fluent
import Foundation
import Dispatch



let drop = Droplet()
let internalVarAccessQueue = DispatchQueue(label: "net.emillet.domo.internalVarAccessQueue")


let _ = drop.config["app", "key"]?.string ?? ""

_ = ThermostatController()
_ = RollerShuttersController()


drop.middleware.append(SampleMiddleware())
let port = drop.config["app", "port"]?.int ?? 80
drop.log.enabled =  [.error, .fatal]
drop.run()
