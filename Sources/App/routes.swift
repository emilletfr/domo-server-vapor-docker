import Vapor
import RxSwift

let rollerShuttersViewController = RollerShuttersViewController()

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  
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
}
