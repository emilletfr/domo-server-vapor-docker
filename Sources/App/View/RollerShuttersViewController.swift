//
//  RollerShuttersViewController.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import Vapor
import RxSwift
//import Run

struct ReturnValue: Content {
    let value: Int
}

final class RollerShuttersViewController
{
    let viewModel : RollerShuttersViewModelable
    var manualAutomaticMode = 0
    var currentPositions = Array(repeating: 0, count: Place.count.rawValue)
    var targetPositions = Array(repeating: 0, count: Place.count.rawValue)
    
    init(viewModel:RollerShuttersViewModelable/* = RollerShuttersViewModel()*/)
    {
        
        self.viewModel = viewModel
        // Set Initial Values in view model
        /*
        viewModel.manualAutomaticModePublisher.onNext(0)
        // Subscribe to view model
        _ = viewModel.manualAutomaticModeObserver.subscribe(onNext: { self.manualAutomaticMode = $0 })
        for placeIndex in 0..<Place.count.rawValue {
            _ = viewModel.currentPositionObserver[placeIndex].subscribe(onNext:{ self.currentPositions[placeIndex] = $0 })
        }
        for placeIndex in 0..<Place.count.rawValue {
            _ = viewModel.targetPositionObserver[placeIndex].subscribe(onNext:{ self.targetPositions[placeIndex] = $0 })
        }
 */
    }
    
    //MARK: Manage Mode: Manual or Automatic: open/close at sunrise/sunset
  //  var ee: InBedService?
    func getWindowsCoveringManualOrAutomaticMode(_ req: Request) throws -> Future<ReturnValue> {
     //   defer {if ee == nil {ee = InBedService(refreshPeriod: 10)}}
        return req.future().transform(to: ReturnValue(value: manualAutomaticMode))
    }
    
    func setWindowsCoveringManualOrAutomaticMode(_ req: Request) throws -> Future<ReturnValue> {
        let value = try req.parameters.next(Int.self)
        defer {self.viewModel.manualAutomaticModePublisher.onNext(value)}
        return req.future().transform(to: ReturnValue(value: value))
    }
    
    //MARK: Manage Positions
    
    func getWindowCoveringCurrentPosition(_ req: Request) throws -> Future<ReturnValue> {
        let index = try req.parameters.next(Int.self)
        return req.future().transform(to: ReturnValue(value:currentPositions[index]))
    }
    
    func getWindowCoveringTargetPosition(_ req: Request) throws -> Future<ReturnValue> {
        let index = try req.parameters.next(Int.self)
        return req.future().transform(to: ReturnValue(value:targetPositions[index]))
    }
    
    func setWindowCoveringTargetPosition(_ req: Request) throws -> Future<ReturnValue> {
        let index = try req.parameters.next(Int.self)
        let position = try req.parameters.next(Int.self)
        defer {viewModel.targetPositionPublisher[index].onNext(position)}
        return req.future().transform(to: ReturnValue(value:position))
    }
}