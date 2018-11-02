//
//  RollerShuttersViewController.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import Vapor
import RxSwift

struct ReturnIntValue: Content {
    let value: Int
}

struct ReturnDoubleValue: Content {
    let value: Double
}

final class RollerShuttersViewController
{
    var viewModel : RollerShuttersViewModelable!
    var manualAutomaticMode = 0
    var currentPositions = Array(repeating: 0, count: RollerShutter.count.rawValue)
    var targetPositions = Array(repeating: 0, count: RollerShutter.count.rawValue)
    
    func start(viewModel:RollerShuttersViewModelable = RollerShuttersViewModel()) {
        self.viewModel = viewModel
        
        // Set Initial Values in view model
        viewModel.manualAutomaticModePublisher.onNext(0)
        
        // Subscribe to view model
        _ = viewModel.manualAutomaticModeObserver.subscribe(onNext: { self.manualAutomaticMode = $0 })
        for placeIndex in 0..<RollerShutter.count.rawValue {
            _ = viewModel.currentPositionObserver[placeIndex].subscribe(onNext:{ self.currentPositions[placeIndex] = $0 })
        }
        for placeIndex in 0..<RollerShutter.count.rawValue {
            _ = viewModel.targetPositionObserver[placeIndex].subscribe(onNext:{ self.targetPositions[placeIndex] = $0 })
        }
    }
    
    //MARK: Manage Mode: Manual or Automatic: open/close at sunrise/sunset
    
    func getWindowsCoveringManualOrAutomaticMode(_ req: Request) throws -> Future<ReturnIntValue> {
        return req.future().transform(to: ReturnIntValue(value: manualAutomaticMode))
    }
    
    func setWindowsCoveringManualOrAutomaticMode(_ req: Request) throws -> Future<ReturnIntValue> {
        let value = try req.parameters.next(Int.self)
        defer {self.viewModel.manualAutomaticModePublisher.onNext(value)}
        return req.future().transform(to: ReturnIntValue(value: value))
    }
    
    //MARK: Manage Positions
    
    func getWindowCoveringCurrentPosition(_ req: Request) throws -> Future<ReturnIntValue> {
        print(req.debugDescription)
        let index = try req.parameters.next(Int.self)
        return req.future().transform(to: ReturnIntValue(value:currentPositions[index]))
    }
    
    func getWindowCoveringTargetPosition(_ req: Request) throws -> Future<ReturnIntValue> {
        print(req.debugDescription)
        let index = try req.parameters.next(Int.self)
        return req.future().transform(to: ReturnIntValue(value:targetPositions[index]))
    }
    
    func setWindowCoveringTargetPosition(_ req: Request) throws -> Future<ReturnIntValue> {
        print(req.debugDescription)
        let index = try req.parameters.next(Int.self)
        let position = try req.parameters.next(Int.self)
        defer {self.viewModel.targetPositionPublisher[index].onNext(position)}
        return req.future().transform(to: ReturnIntValue(value:position))
    }
}
