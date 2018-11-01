import Vapor
import RxSwift

var app: Application!
let secondEmitter = PublishSubject<Int>()


/// Called after your application has initialized.
public func boot(_ application: Application) throws {
    app = application
 //   _ = InBedService()
    //_ = SunriseSunsetService()
    let rs = RollerShutterService()
  //  rs.currentPositionObserver[0].onNext(0)
    let state = 100
    rs.targetPositionPublisher[0].onNext(state)
    rs.targetPositionPublisher[1].onNext(state)
    rs.targetPositionPublisher[2].onNext(state)
    rs.targetPositionPublisher[3].onNext(state)
    rs.targetPositionPublisher[4].onNext(state)
    
    func repeatedTask(task: RepeatedTask) {
        let secondsTimeStamp = Int(Date().timeIntervalSince1970)
        secondEmitter.onNext(secondsTimeStamp)
    }
    app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: TimeAmount.seconds(1), repeatedTask)
}
