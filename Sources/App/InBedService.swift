//
//  inBedController.swift
//  VaporApp
//
//  Created by Eric on 28/11/2016.
//
//

import Foundation
import Dispatch
import Vapor
import HTTP

//let ff   = InbedService()

class InbedServiceDefault
{
    static let shared  = InbedService<HttpToJsonClient>()
    private init() {} //This prevents others from using the default '()' initializer for this class.
}

protocol InbedServiceable : Equatable
{
    var isInBed : Bool? {get}
    var isBusy : Bool? {get}
    func subscribe(isInBedDidChange:@escaping ((Void) -> Void), isBusyDidChange:@escaping ((Void) -> Void))
}

func ==<T:InbedServiceable>(lhs: T, rhs: T) -> Bool {
    guard let lhsisInBed = lhs.isInBed, let rhsisInBed = rhs.isInBed, let lhsIsBusy = lhs.isBusy, let rhsIsBusy = rhs.isBusy else  {return false}
    return lhsisInBed == rhsisInBed && lhsIsBusy == rhsIsBusy
}

class InbedService<HttpToJsonClientableClass:HttpToJsonClientable>: InbedServiceable , MinuteRepeatTimer
{
    var isInBed : Bool? {didSet {if oldValue != isInBed {for callback in isInBedDidChangeForRegisteredOnes{callback()}}}}
    var isBusy : Bool? {didSet {if oldValue != isInBed { for callback in isBusyDidChangeForRegisteredOnes {callback()}}}}
    private var isInBedDidChangeForRegisteredOnes = [((Void) -> Void)]()
    private var isBusyDidChangeForRegisteredOnes = [((Void) -> Void)]()
    let httpToJsonClient = HttpToJsonClientableClass()

    private var subscribedIndex = 0
    
    init()
    {
        startMinuteRepeatTimer()
    }

    func subscribe(isInBedDidChange:@escaping ((Void) -> Void), isBusyDidChange:@escaping ((Void) -> Void))
    {
        isInBedDidChangeForRegisteredOnes += isInBedDidChange
        isBusyDidChangeForRegisteredOnes += isBusyDidChange
        subscribedIndex += 1
    }
    
    func minuteRepeatTimerFired()
    {
        let items = httpToJsonClient.fetch(url: "http://10.0.1.24/status", jsonPaths: "inBed")
        guard let item = items?[0] else {return}
        self.isInBed = Int(item) == 1
    }
}
