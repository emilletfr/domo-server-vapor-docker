import Vapor
import RxSwift

// In order to debug with Xcode :
// replace in homebridge config.json : ip address by the address of this PC and set port to 80
// add this to the Run Scheme / Arguments passed on launch :
// --hostname 0.0.0.0 --port 80

var app: Application!
let isHomeKitModulesNetworkIpOrDns: Bool = true
let secondEmitter = PublishSubject<Int>()

/// Called after your application has initialized.
public func boot(_ application: Application) throws {
    app = application
    rollerShuttersViewController.start()
    thermostatViewController.start()
    var hundredMilliSecondCount = 0
    func repeatedTask(task: RepeatedTask) {
        let secondsTimeStamp = Int(Date().timeIntervalSince1970)
        secondEmitter.onNext(secondsTimeStamp)
    }
    app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: TimeAmount.milliseconds(1000), repeatedTask)
}
