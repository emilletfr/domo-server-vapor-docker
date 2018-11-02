import Vapor
import RxSwift

let rollerShuttersViewController = RollerShuttersViewController()
let thermostatViewController = ThermostatViewController()

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    // Roller Shutters routes
  
    let rs = rollerShuttersViewController

    router.group("windows-covering-manual-automatic-mode") { router in
        router.get("getOn", use: rs.getWindowsCoveringManualOrAutomaticMode)
        router.get("setOn", Int.parameter, use: rs.setWindowsCoveringManualOrAutomaticMode)
    }
    
    router.group("window-covering") { router in
        router.get("getCurrentPosition", Int.parameter, use: rs.getWindowCoveringCurrentPosition)
        router.get("getTargetPosition", Int.parameter, use: rs.getWindowCoveringTargetPosition)
        router.get("setTargetPosition", Int.parameter, Int.parameter, use: rs.setWindowCoveringTargetPosition)
    }
    
    // Thermostat routes
    
    let th = thermostatViewController
    
    router.group("boiler-heating-level") { router in
     router.get("getCurrentRelativeHumidity", use: th.getBoilerHeatingLevelCurrentRelativeHumidity)
    }
    
    router.group("force-hot-water") { router in
        router.get("getOn", use: th.getForceHotWater)
        router.get("setOn", Int.parameter, use: th.setForceHotWater)
    }
    
    router.group("thermostat") { router in
        router.get("getCurrentHeatingCoolingState", use: th.getThermostatCurrentHeatingCoolingState)
        router.get("getTargetHeatingCoolingState", use: th.getThermostatTargetHeatingCoolingState)
        router.get("setTargetHeatingCoolingState", Int.parameter, use: th.setThermostatTargetHeatingCoolingState)
        router.get("getCurrentTemperature", use: th.getThermostatCurrentTemperature)
        router.get("getTargetTemperature", use: th.getThermostatTargetTemperature)
        router.get("setTargetTemperature", Double.parameter, use: th.setThermostatTargetTemperature)
        router.get("getTemperatureDisplayUnits", use: th.getThermostatTemperatureDisplayUnits)
        router.get("setTemperatureDisplayUnits", Int.parameter, use: th.setThermostatTemperatureDisplayUnits)
    }
    
    router.group("temperature-sensor") { router in
        router.get("getCurrentTemperature", use: th.getTemperatureSensorCurrentTemperature)
    }
    
    router.group("humidity-sensor") { router in
        router.get("getCurrentRelativeHumidity", use: th.getHumiditySensorCurrentRelativeHumidity)
    }
}
