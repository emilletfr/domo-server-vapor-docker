//
//  RollerShutterService.swift
//  VaporApp
//
//  Created by Eric on 14/12/2016.
//
//

import Dispatch
import RxSwift
import Foundation

enum Place: Int { case LIVING_ROOM = 0, DINING_ROOM, OFFICE, KITCHEN, BEDROOM, count }

protocol RollerShutterServicable
{
    var currentPositionObserver : [PublishSubject<Int>] {get}
    var targetPositionObserver : [PublishSubject<Int>] {get}
    var currentAllPositionObserver : PublishSubject<Int> {get}
    var targetAllPositionObserver : PublishSubject<Int> {get}
    
    var targetPositionPublisher : [PublishSubject<Int>] {get}
    var targetAllPositionPublisher : PublishSubject<Int>{get}
    
    init(_ httpClient : HttpClientable)
}

final class RollerShutterService : RollerShutterServicable
{
    let currentPositionObserver = [PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>()]
    let targetPositionObserver = [PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>()]
    let currentAllPositionObserver = PublishSubject<Int>()
    let targetAllPositionObserver = PublishSubject<Int>()
    
    let targetPositionPublisher = [PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>(),PublishSubject<Int>()]
    let targetAllPositionPublisher = PublishSubject<Int>()
    
    let httpClient : HttpClientable
    
    required init( _ httpClient : HttpClientable = HttpClient())
    {
        self.httpClient = httpClient
        self.reduce()
    }
    
    func reduce()
    {
        for placeIndex in 0..<Place.count.rawValue
        {
            // Wrap to Initial State
            DispatchQueue.global().async
                {
                    guard let response = self.httpClient.sendGet("http://10.0.1.1\(placeIndex)/status"), let position = response.parseToIntFrom(path:["open"]) else
                    {
                        //   self.currentPositionObserver[placeIndex].onError(self)
                        //  self.targetPositionObserver[placeIndex].onError(self)
                        return
                    }
                    self.currentPositionObserver[placeIndex].onNext(position*100)
                    self.targetPositionObserver[placeIndex].onNext(position*100)
            }
            
            // Wrap to Single command
            _ = Observable.combineLatest(currentPositionObserver[placeIndex], targetPositionObserver[placeIndex], targetPositionPublisher[placeIndex].debounce(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)), resultSelector: {(currentObs:$0, targetObs:$1, targetPub:$2)})
                .distinctUntilChanged({($0.2 == $1.2)})
                .filter({$0.0 == $0.1})
                .subscribe(onNext: { (currentObs: Int, targetObs: Int, targetPub:Int) in
                    DispatchQueue.global().async
                        {
                            self.targetPositionObserver[placeIndex].onNext(targetPub)
                            let open = targetPub > currentObs ? "1" : "0"
                            let urlString = "http://10.0.1.1\(placeIndex)/\(open)"
                            _ = self.httpClient.sendGet(urlString)
                            let offset = currentObs > targetPub ? currentObs - targetPub : targetPub - currentObs
                            var delay = 140000*(offset)
                            if targetPub == 0 || targetPub == 100 {delay = 14_000_000}
                            usleep(useconds_t(delay))
                            _ = self.httpClient.sendGet(urlString)
                            self.currentPositionObserver[placeIndex].onNext(targetPub)
                    }
                })
            
            let emptyPublisher = PublishSubject<Int>()
            
            // Wrap to All command (Activate One by One)
            _  = Observable.combineLatest(self.targetAllPositionPublisher, self.currentPositionObserver[placeIndex],
                                          resultSelector: {(($0 == $1), $0)})
                .filter{$0.0 == true}
                .map({$0.1})
                .subscribe(placeIndex + 1 >= Place.count.rawValue ? emptyPublisher : self.targetPositionPublisher[placeIndex + 1])
        }
        _ = self.targetAllPositionPublisher.subscribe(self.targetPositionPublisher[Place.LIVING_ROOM.rawValue])
        
        //  Wrap to Update AllRollingShutter position
        _  = Observable.combineLatest(self.currentPositionObserver, {$0.reduce(0, { (result:Int, value:Int) in return result+value })/$0.count })
        //    .filter{$0 == 0 || $0 == 100}
            .subscribe(self.currentAllPositionObserver)
    }
}



