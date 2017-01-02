//
//  TimerRepeatable.swift
//  VaporApp
//
//  Created by Eric on 12/12/2016.
//
//

import Foundation

protocol RepeatTimer
{
  //  func startRepeatTimerWithRepeatDelay(delay:Int)
    func repeatTimerFired()
}

extension RepeatTimer
{
     func startRepeatTimerWithRepeatDelay(delay:Int)
    {
        DispatchQueue.global(qos:.default).async {
            while (true)
            {
                self.repeatTimerFired()
                sleep(UInt32(delay))
            }
        }
    }
}
