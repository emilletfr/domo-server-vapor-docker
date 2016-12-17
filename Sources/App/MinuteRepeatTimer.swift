//
//  MinuteRepeatTimer.swift
//  VaporApp
//
//  Created by Eric on 13/12/2016.
//
//

import Foundation

protocol MinuteRepeatTimer: class, RepeatTimer
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
        startRepeatTimerWithRepeatDelay(delay: 60)
    }
 }


