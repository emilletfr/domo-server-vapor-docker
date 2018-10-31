import Vapor
import RxSwift

struct VM: RollerShuttersViewModelable {
    var currentPositionObserver: [PublishSubject<Int>]
    
    var targetPositionObserver: [PublishSubject<Int>]
    
    var manualAutomaticModeObserver: PublishSubject<Int>
    
    var targetPositionPublisher: [PublishSubject<Int>]
    
    var manualAutomaticModePublisher: PublishSubject<Int>
    
    init(_ rollerShuttersService: RollerShutterServicable, _ inBedService: InBedServicable, _ sunriseSunsetService: SunriseSunsetServicable, _ timePublisher: Observable<String>) {
        currentPositionObserver = [PublishSubject()]
        targetPositionObserver = [PublishSubject()]
        manualAutomaticModeObserver = PublishSubject()
        targetPositionPublisher = [PublishSubject()]
        manualAutomaticModePublisher = PublishSubject()
    }
    
}

struct RSS: RollerShutterServicable {
    var currentPositionObserver: [PublishSubject<Int>]
    
    var targetPositionObserver: [PublishSubject<Int>]
    
    var targetPositionPublisher: [PublishSubject<Int>]
    
    init(httpClient: HttpClientable) {
        currentPositionObserver = [PublishSubject()]
        targetPositionObserver = [PublishSubject()]
        targetPositionPublisher = [PublishSubject()]
    }
    
}

struct IBS: InBedServicable {
    var isInBedObserver: PublishSubject<Bool>
    
    init(httpClient: HttpClientable, refreshPeriod: Int) {
        isInBedObserver = PublishSubject()
    }
}

struct SSS: SunriseSunsetServicable {
    var sunriseTimeObserver: PublishSubject<String>
    
    var sunsetTimeObserver: PublishSubject<String>
    
    init(httpClient: HttpClientable, refreshPeriod: Int) {
        sunriseTimeObserver = PublishSubject()
         sunsetTimeObserver = PublishSubject()
    }
}

struct HC: HttpClientable {
    func send<T>(url: String, responseType: T.Type) -> Observable<T> where T : Decodable {
        return Observable<T>.create { observer in
            return Disposables.create {}
        }
    }

}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  
    let rs = RollerShuttersViewController(viewModel:VM(
        RSS(httpClient: HC()),
        IBS(httpClient: HC(), refreshPeriod: 60),
        SSS(httpClient: HC(), refreshPeriod: 60),
        RepeatTimer.timePublisher().distinctUntilChanged()
    ))

    router.group("windows-covering-manual-automatic-mode") { router in
        router.get("getOn", use: rs.getWindowsCoveringManualOrAutomaticMode)
        router.get("setOn", Int.parameter, use: rs.setWindowsCoveringManualOrAutomaticMode)
    }
    
    router.group("window-covering") { router in
        router.get("getCurrentPosition", Int.parameter, use: rs.getWindowCoveringCurrentPosition)
        router.get("getTargetPosition", Int.parameter, use: rs.getWindowCoveringTargetPosition)
        router.get("setTargetPosition", Int.parameter, Int.parameter, use: rs.setWindowCoveringTargetPosition)
    }
}
