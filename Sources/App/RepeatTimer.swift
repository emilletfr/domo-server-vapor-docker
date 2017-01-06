//
//  TimerRepeatable.swift
//  VaporApp
//
//  Created by Eric on 12/12/2016.
//
//

import Foundation
import Dispatch



protocol RepeatTimerable
{
    var delay : UInt32 {get}
   // var didFire : (Void) -> () {get set}
    init()
}

extension RepeatTimerable
{
    init(didFireBlock: @escaping ((Void) -> ()))
    {
        self.init()
        let delay = UInt32(self.delay)
        DispatchQueue.global(qos:.default).async {
            while (true)
            {
                didFireBlock()
                sleep(delay)
            }
        }
    }

}

class HourRepeatTimer : RepeatTimerable
{
    var delay: UInt32 = 60*60
    required init() {}
}

class MinuteRepeatTimer : RepeatTimerable
{
    var delay: UInt32 = 60
    required init() {}
}

class SecondRepeatTimer : RepeatTimerable
{
    var delay: UInt32 = 1
    required init() {}
}
