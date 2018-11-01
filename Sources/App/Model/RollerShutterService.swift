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
            _ = self.httpClient.send(url: "http://10.0.1.1\(placeIndex)/status", responseType: RollerShutterResponse.self)
                .map({ (r) -> Int in return r.open*100 })
                .subscribe(onNext: { (position) in
                    self.currentPositionObserver[placeIndex].onNext(position)
                    self.targetPositionObserver[placeIndex].onNext(position)
                })
            
            // Wrap to Single command
            _ = Observable.combineLatest(self.currentPositionObserver[placeIndex], self.targetPositionPublisher[placeIndex])
                .filter { $0.0 != $0.1 }
                .flatMap({ (current:Int, target:Int) -> Observable<Int> in return self.action(placeIndex, current, target) })
                .subscribe(onNext: { (target:Int) in
                self.currentPositionObserver[placeIndex].onNext(target)
                self.targetPositionObserver[placeIndex].onNext(target)
            })
        }
    }
    
    func action(_ placeIndex:Int, _ currentPosition:Int, _ targetPosition:Int) -> Observable<Int>  {
        let open = targetPosition > currentPosition ? "1" : "0"
        let urlString = "http://10.0.1.1\(placeIndex)/\(open)"
        let offset = currentPosition > targetPosition ? currentPosition - targetPosition : targetPosition - currentPosition
        var delay : Int = Int(offset*14/100)
        print(delay)
        if targetPosition == 0 || targetPosition == 100 {delay = 14}
        
        return self.httpClient.send(url: urlString, responseType: RollerShutterResponse.self)
            .flatMap({ _ in return secondEmitter })
            .skip(delay)
            .take(1)
            .flatMap({_ in return self.httpClient.send(url: urlString, responseType: RollerShutterResponse.self)})
            .map({ _ in return targetPosition})
    }
    
    struct RollerShutterResponse: Decodable
    {
        let open: Int
    }
}
