//
//  RollerShutterService.swift
//  VaporApp
//
//  Created by Eric on 14/12/2016.
//
//

import Dispatch
import RxSwift
import Foundation

protocol RollerShutterServicable
{
    var currentPositionObserver : [PublishSubject<Int>] {get}
    var targetPositionObserver : [PublishSubject<Int>] {get}
    
    var targetPositionPublisher : [PublishSubject<Int>] {get}
    
    init(httpClient: HttpClientable)
}
