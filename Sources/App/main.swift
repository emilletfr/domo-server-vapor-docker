import Vapor


let drop = Droplet()

let thermostatViewController = ThermostatViewController()
//let rollerShuttersViewController = RollerShuttersViewController()

drop.log.enabled =  [.error, .fatal]
drop.run()


