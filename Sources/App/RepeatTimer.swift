//
//  TimerRepeatable.swift
//  VaporApp
//
//  Created by Eric on 12/12/2016.
//
//

import Foundation
import Dispatch


class RepeatTimer
{
    var didFireBlock : (Void) -> () = {}
    init(delay:UInt32)
    {
        DispatchQueue.global(qos:.default).async {
            sleep(1)
            self.didFireBlock()
            while (true)
            {
                sleep(delay)
                self.didFireBlock()
            }
        }
    }
}

/*
protocol RepeatTimerable
{
    var delay : UInt32 {get}
   // var didFire : (Void) -> () {get set}
    var didFireBlock : (Void) -> () {get set}
    init()
}

extension RepeatTimerable
{
    init(delay:UInt32)
    {
        self.init()
      //  let delay = UInt32(self.delay)
        DispatchQueue.global(qos:.default).async {
            while (true)
            {
                self.didFireBlock()
                sleep(delay)
            }
        }
    }

}
 */
/*
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
*/
