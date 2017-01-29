//
//  RollerShuttersViewController.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import Vapor
import RxSwift


final class RollerShuttersViewController
{
    let viewModel : RollerShuttersViewModelable
    
    init(viewModel:RollerShuttersViewModelable = RollerShuttersViewModel())
    {
        self.viewModel = viewModel
        
        // Set Initial Values
        
        viewModel.manualAutomaticModePublisher.onNext(0)
        
        //MARK: Manage Mode: Manual or Automatic: open/close at sunrise/sunset
        
        var manualAutomaticMode = 0
        _ = viewModel.manualAutomaticModeObserver.subscribe(onNext: { manualAutomaticMode = $0 })
        drop.get("windows-covering-manual-automatic-mode/getOn")
        { request in
            return  try JSON(node: ["value": manualAutomaticMode])
        }
        
        drop.get("windows-covering-manual-automatic-mode/setOn", Int.self)
        { request, value in
            viewModel.manualAutomaticModePublisher.onNext(value)
            return try JSON(node: ["value": value])
        }
        
        //MARK: Manage Positions
        
        var currentPositions = Array(repeating: 0, count: Place.count.rawValue)
        for placeIndex in 0..<Place.count.rawValue
        {
            _ = viewModel.currentPositionObserver[placeIndex].subscribe(onNext:{ currentPositions[placeIndex] = $0 })
        }
        drop.get("window-covering/getCurrentPosition", Int.self)
        { request, index in
            return try JSON(node: ["value": currentPositions[index]])
        }
        
        var targetPositions = Array(repeating: 0, count: Place.count.rawValue)
        for placeIndex in 0..<Place.count.rawValue
        {
            _ = viewModel.targetPositionObserver[placeIndex].subscribe(onNext:{ targetPositions[placeIndex] = $0 })
        }
        drop.get("window-covering/getTargetPosition", Int.self)
        { request, index in
            return try JSON(node: ["value": targetPositions[index]])
        }
        
        drop.get("window-covering/setTargetPosition", Int.self, Int.self)
        { request, index, position in
            viewModel.targetPositionPublisher[index].onNext(position)
            return try JSON(node: ["value": position])
        }
    }
}
