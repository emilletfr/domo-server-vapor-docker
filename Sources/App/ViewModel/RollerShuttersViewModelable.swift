//
//  RollerShuttersViewModel.swift
//  VaporApp
//
//  Created by Eric on 20/12/2016.
//
//

import Foundation
import RxSwift
import Dispatch


protocol RollerShuttersViewModelable
{
    //MARK: Subscriptions
    var currentPositionObserver : [PublishSubject<Int>] {get}
    var targetPositionObserver : [PublishSubject<Int>] {get}
    var manualAutomaticModeObserver : PublishSubject<Int> {get}
    //MARK: Actions
    var targetPositionPublisher : [PublishSubject<Int>] {get}
    var manualAutomaticModePublisher : PublishSubject<Int> {get}
    //MARK: Dispatcher
    init(rollerShuttersService:RollerShutterServicable, inBedService:InBedServicable, sunriseSunsetService:SunriseSunsetServicable)
}

