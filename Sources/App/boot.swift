import Vapor


var app: Application!

/// Called after your application has initialized.
public func boot(_ application: Application) throws {
    // your code here
    app = application
    app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: TimeAmount.seconds(1)) { (task:RepeatedTask) in
        print("\(Date().timeIntervalSince1970)")
    }
}
