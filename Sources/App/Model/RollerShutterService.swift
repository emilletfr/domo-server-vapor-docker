//
//  RollerShutterService.swift
//  VaporApp
//
//  Created by Eric on 14/12/2016.
//
//

import RxSwift

final class RollerShutterService : RollerShutterServicable
{
    let currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let targetPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    
    let targetPositionPublisher = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    
    let httpClient : HttpClientable
    
    required init(httpClient : HttpClientable = HttpClient()) {
        self.httpClient = httpClient
        self.reduce()
    }
    
    func reduce() {
        for placeIndex in 0..<Place.count.rawValue {
            // Wrap to Initial State
            let response = self.httpClient.send(url: "http://10.0.1.1\(placeIndex)/status", responseType: RollerShutterResponse.self)
                .map({ (r) -> Int in return r.open*100 })
            _ = response.subscribe(self.currentPositionObserver[placeIndex])
            _ = response.subscribe(self.targetPositionObserver[placeIndex])
            
            // Wrap to Single command
            _ = Observable.combineLatest(currentPositionObserver[placeIndex], targetPositionObserver[placeIndex], targetPositionPublisher[placeIndex].debounce(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)), resultSelector: {(currentObs:$0, targetObs:$1, targetPub:$2)})
                .filter({$0.0 != $0.2 && $0.1 != $0.2})
                .subscribe(onNext: { (currentObs: Int, targetObs: Int, targetPub:Int) in
                    self.targetPositionObserver[placeIndex].onNext(targetPub)
                    self.action(placeIndex, currentObs, targetPub)
                })
        }
    }
    
    func action(_ placeIndex:Int, _ currentPosition:Int, _ targetPosition:Int) {
        let open = targetPosition > currentPosition ? "1" : "0"
        let urlString = "http://10.0.1.1\(placeIndex)/\(open)"
        let offset = currentPosition > targetPosition ? currentPosition - targetPosition : targetPosition - currentPosition
        var delay : Int = Int(offset*14/100)
        print(delay)
        if targetPosition == 0 || targetPosition == 100 {delay = 14}
        
        _ = self.httpClient.send(url: urlString, responseType: RollerShutterResponse.self)
            .flatMap({ _ in return secondEmitter })
            .skip(delay)
            .take(1)
            .flatMap({_ in return self.httpClient.send(url: urlString, responseType: RollerShutterResponse.self)})
            .map({ _ in return targetPosition})
            .subscribe(self.currentPositionObserver[placeIndex])
    }
    
    struct RollerShutterResponse: Decodable
    {
        let open: Int
    }
}
