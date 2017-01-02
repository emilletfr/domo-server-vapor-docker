import Vapor
import HTTP
import Fluent
import Foundation
import Dispatch



let drop = Droplet()
let internalVarAccessQueue = DispatchQueue(label: "net.emillet.domo.internalVarAccessQueue")

//let sunriseSunsetController = SunriseSunsetController()
//_ = ThermostatController()
//_ = RollerShuttersController()

drop.log.enabled =  [.error, .fatal]
drop.run()
