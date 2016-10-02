import Foundation

class VaporTimer
{
    /*
    public class func every(interval: TimeInterval, _ block: () -> Void) -> Void
    {
        let queue = DispatchQueue.global(qos: .utility)
        while (true) {
            let semaphore = DispatchSemaphore(value: 0)
            let deadlineTime = DispatchTime.now() + interval//.seconds(interval)
            queue.asyncAfter(deadline: deadlineTime) {semaphore.signal()}
            _ = semaphore.wait(timeout: .distantFuture)
            block()
            
        }
    }
 */
}


/*
 self.retrieveTimer?.cancel()
 self.retrieveTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
 self.retrieveTimer?.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.seconds(3600))
 self.retrieveTimer?.setEventHandler(handler: self.retrieveTemp)
 self.retrieveTimer?.resume()
 
 */
