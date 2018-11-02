import Vapor
import RxSwift

var app: Application!
let isHomeKitModulesNetworkIpOrDns: Bool = true
let secondEmitter = PublishSubject<Int>()
let hundredMilliSecondEmitter = PublishSubject<Int>()

/// Called after your application has initialized.
public func boot(_ application: Application) throws {
    app = application
    rollerShuttersViewController.start()
    thermostatViewController.start()
    var hundredMilliSecondCount = 0
    func repeatedTask(task: RepeatedTask) {
        let secondsTimeStamp = Int(Date().timeIntervalSince1970)
        hundredMilliSecondEmitter.onNext(secondsTimeStamp)
        hundredMilliSecondCount += 1
        if (hundredMilliSecondCount%10 == 0) {
            secondEmitter.onNext(secondsTimeStamp)
        }
    }
    app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: TimeAmount.milliseconds(100), repeatedTask)
}
