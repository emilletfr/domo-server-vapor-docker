//import App
import XCTest
import RxSwift


@testable import App

final class AppTests: XCTestCase
{
    let mockRollerShutterService   = MockRollerShutterService(httpClient: HttpClient())
    let mockInBedService   = MockInBedService(httpClient: HttpClient(), refreshPeriod: 0)
    let mockSunriseSunsetService   = MockSunriseSunsetService(httpClient: HttpClient(), refreshPeriod: 0)
    var t: RollerShuttersViewModel!
    var responses = [Int: Int]()
    
    override func setUp() {
        responses = [Int: Int]()
        t = RollerShuttersViewModel(rollerShuttersService: mockRollerShutterService, inBedService: mockInBedService, sunriseSunsetService: mockSunriseSunsetService, secondEmitter: PublishSubject<Int>())
        t.manualAutomaticModePublisher.onNext(0)
        for placeIndex in 0..<RollerShutter.count.rawValue {
            _ = mockRollerShutterService.targetPositionPublisher[placeIndex].subscribe(onNext: { position in
                self.responses[placeIndex] = position
            })
        }
    }
    
    func testRollerShuttersBehaviorAtDaylightWhenAutoModeAndIsInBed() throws {
        let testScheduler = TestScheduler(initialClock: 0)
    }
    
    func testRollerShuttersBehaviorAtSunriseWhenManualModeAndIsInBed() throws {
        t.hourMinutePublisher.onNext(mockSunriseSunsetService.sunriseTime)
        t.manualAutomaticModePublisher.onNext(1)
        mockInBedService.isInBedObserver.onNext(true)
        //Then expect open all roller shutters except bedroom
        XCTAssertEqual(responses, [:])
    }
    
    func testRollerShuttersBehaviorAtSunriseWhenManualModeAndIsNotInBed() throws {
        t.hourMinutePublisher.onNext(mockSunriseSunsetService.sunriseTime)
        t.manualAutomaticModePublisher.onNext(1)
        mockInBedService.isInBedObserver.onNext(false)
        //Then expect open all roller shutters except bedroom
        XCTAssertEqual(responses, [:])
    }
    
    func testRollerShuttersBehaviorAtSunriseWhenAutoModeAndIsInBed() throws {
        t.hourMinutePublisher.onNext(mockSunriseSunsetService.sunriseTime)
        t.manualAutomaticModePublisher.onNext(0)
        mockInBedService.isInBedObserver.onNext(true)
        //Then expect open all roller shutters except bedroom
        XCTAssertEqual(responses, [0: 100, 1: 100, 2: 100, 3: 100])
    }
    
    func testRollerShuttersBehaviorAtSunriseWhenAutoModeAndIsNotInBed() throws {
        t.hourMinutePublisher.onNext(mockSunriseSunsetService.sunriseTime)
        t.manualAutomaticModePublisher.onNext(0)
        mockInBedService.isInBedObserver.onNext(false)
        //Then expect open all roller shutters
        XCTAssertEqual(responses, [0: 100, 1: 100, 2: 100, 3: 100, 4: 100])
    }
    
    func testRollerShuttersBehaviorAtSunsetWhenManualModeAndIsInBed() throws {
        t.hourMinutePublisher.onNext(mockSunriseSunsetService.sunsetTime)
        t.manualAutomaticModePublisher.onNext(1)
        mockInBedService.isInBedObserver.onNext(true)
        //Then expect close all roller shutters
        XCTAssertEqual(responses, [0: 0, 1: 0, 2: 0, 3: 0, 4: 0])
    }
    
    func testRollerShuttersBehaviorAtSunsetWhenManualModeAndIsNotInBed() throws {
        t.hourMinutePublisher.onNext(mockSunriseSunsetService.sunsetTime)
        t.manualAutomaticModePublisher.onNext(1)
        mockInBedService.isInBedObserver.onNext(false)
        //Then expect close all roller shutters
        XCTAssertEqual(responses, [0: 0, 1: 0, 2: 0, 3: 0, 4: 0])
    }
    
    func testRollerShuttersBehaviorAtSunsetWhenAutoModeAndIsInBed() throws {
        t.hourMinutePublisher.onNext(mockSunriseSunsetService.sunsetTime)
        t.manualAutomaticModePublisher.onNext(0)
        mockInBedService.isInBedObserver.onNext(true)
        //Then expect close all roller shutters
        XCTAssertEqual(responses, [0: 0, 1: 0, 2: 0, 3: 0, 4: 0])
    }
    
    func testRollerShuttersBehaviorAtSunsetWhenAutoModeAndIsNotInBed() throws {
        t.hourMinutePublisher.onNext(mockSunriseSunsetService.sunsetTime)
        t.manualAutomaticModePublisher.onNext(0)
        mockInBedService.isInBedObserver.onNext(false)
        //Then expect close all roller shutters
        XCTAssertEqual(responses, [0: 0, 1: 0, 2: 0, 3: 0, 4: 0])
    }
    
    func testNothing() throws {
        // add your tests here
        XCTAssert(true)
    }
    
    static let allTests = [
        ("testNothing", testNothing)
    ]
}

final class MockSunriseSunsetService: SunriseSunsetServicable {
    let sunriseTimeObserver = ReplaySubject<String>.create(bufferSize: 1)
    let sunsetTimeObserver = ReplaySubject<String>.create(bufferSize: 1)
    let sunriseTime = "08:00"
    let sunsetTime = "22:00"
    
    init(httpClient: HttpClientable, refreshPeriod: Int) {
        sunriseTimeObserver.onNext(sunriseTime)
        sunsetTimeObserver.onNext(sunsetTime)
    }
}

final class MockRollerShutterService: RollerShutterServicable {
    let currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    var targetPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    
    var targetPositionPublisher = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    
    init(httpClient: HttpClientable) {
    }
}

final class MockInBedService: InBedServicable {
    var isInBedObserver = PublishSubject<Bool>()
    
    init(httpClient: HttpClientable, refreshPeriod: Int) {
    }
}
