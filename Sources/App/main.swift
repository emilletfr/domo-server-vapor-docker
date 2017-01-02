import Vapor
import HTTP
import Fluent
import Foundation
import Dispatch



let drop = Droplet()


struct MockViewModel : RollerShuttersViewModelable
{
    mutating internal func changeAllTarget(position: Int)
    {
        
    }

    var rollerShuttersCurrentPositions : [Int] = [0]
    var rollerShuttersTargetPositions : [Int] = [0]
    
    mutating func changeTarget(shutterIndex index: Int, position: Int)
    {
        rollerShuttersCurrentPositions = [1]
    }
    
}



var rollerShuttersView = RollerShuttersView(rollerShuttersViewModel: MockViewModel())

rollerShuttersView.rollerShuttersViewModel.changeTarget(shutterIndex: 1, position: 1)

let internalVarAccessQueue = DispatchQueue(label: "net.emillet.domo.internalVarAccessQueue")


//let _ = drop.config["app", "key"]?.string ?? ""

//_ = ThermostatController()
//_ = RollerShuttersController()


//drop.middleware.append(SampleMiddleware())
//let port = drop.config["app", "port"]?.int ?? 80
drop.log.enabled =  [.error, .fatal]
drop.run()
