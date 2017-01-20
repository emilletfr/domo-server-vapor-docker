//
//  RollerShuttersViewController.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import Vapor


final class RollerShuttersViewController
{
    var viewModel : RollerShuttersViewModelable!
    
    init(viewModel:RollerShuttersViewModelable = RollerShuttersViewModel())
    {
        self.viewModel = viewModel
        
     //   viewModel.currentPositionObserver.
        drop.get("window-covering/getCurrentPosition", Int.self)
        { request, index in
            let value = 0
            return try JSON(node: ["value": value])
        }
        
        drop.get("window-covering/getTargetPosition", Int.self)
        { request, index in
            let value = 0
            return try JSON(node: ["value": value])
        }
        
        drop.get("window-covering/setTargetPosition", Int.self, Int.self)
        { request, index, position in
            return try JSON(node: ["value": position])
        }
        
        drop.get("window-covering/getCurrentPosition/all")
        { request in
            let value = 0
               return try JSON(node: ["value": value])
        }
        
        drop.get("window-covering/getTargetPosition/all")
        { request in
            let value = 0
            return try JSON(node: ["value": value])
        }
        
        drop.get("window-covering/setTargetPosition/all", Int.self)
        { request, position in
            
            return try JSON(node: ["value": position])
        }

        
    }
}
