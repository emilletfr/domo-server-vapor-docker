import Vapor
import RxSwift

var app: Application!
let secondEmitter = PublishSubject<Int>()


/// Called after your application has initialized.
public func boot(_ application: Application) throws {
    app = application
    _ = InBedService(httpClient: HttpClient(), refreshPeriod: 10)
    
    func repeatedTask(task: RepeatedTask) {
        let secondsTimeStamp = Int(Date().timeIntervalSince1970)
        secondEmitter.onNext(secondsTimeStamp)
    }
    app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: TimeAmount.seconds(1), repeatedTask)
}
