//
//  MinuteRepeatTimer.swift
//  VaporApp
//
//  Created by Eric on 13/12/2016.
//
//

import Foundation
import Dispatch

protocol MinuteRepeatTimer: RepeatTimer
{
    func startMinuteRepeatTimer()
    func minuteRepeatTimerFired()
}

extension MinuteRepeatTimer
{
     func repeatTimerFired()
    {
        self.minuteRepeatTimerFired()
    }
    
    func startMinuteRepeatTimer()
    {
        startRepeatTimerWithRepeatDelay(delay: 5)
    }
 }


