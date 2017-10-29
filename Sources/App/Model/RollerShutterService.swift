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
    
    var targetPositionPublisher : [PublishSubject<Int>] {get}
    
    init(_ httpClient : HttpClientable)
}


final class RollerShutterService : RollerShutterServicable
{
    let currentPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    let targetPositionObserver = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    
    let targetPositionPublisher = [PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>(), PublishSubject<Int>()]
    
    let actionSerialQueue = DispatchQueue(label: "net.emillet.domo.RollerShutterService")
    let httpClient : HttpClientable
    
    required init( _ httpClient : HttpClientable = HttpClient())
    {
        self.httpClient = httpClient
        self.reduce()
    }
    
    func reduce()
    {
        for placeIndex in 0..<Place.count.rawValue {
            // Wrap to Initial State
            DispatchQueue.global().async {
                    guard let response = self.httpClient.sendGet("http://10.0.1.1\(placeIndex)/status"), let position = response.parseToIntFrom(path:["open"])
                        else {
                        //   self.currentPositionObserver[placeIndex].onError(self)
                        //  self.targetPositionObserver[placeIndex].onError(self)
                        return
                    }
                    self.currentPositionObserver[placeIndex].onNext(position*100)
                    self.targetPositionObserver[placeIndex].onNext(position*100)
            }
            
            // Wrap to Single command
            _ = Observable.combineLatest(currentPositionObserver[placeIndex], targetPositionObserver[placeIndex], targetPositionPublisher[placeIndex].debounce(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)), resultSelector: {(currentObs:$0, targetObs:$1, targetPub:$2)})
                .filter({$0.0 != $0.2 && $0.1 != $0.2})
                .subscribe(onNext: { (currentObs: Int, targetObs: Int, targetPub:Int) in
                    self.targetPositionObserver[placeIndex].onNext(targetPub)
                    self.action(placeIndex, currentObs, targetPub)
                })
        }
    }
    
    func action(_ placeIndex:Int, _ currentPosition:Int, _ targetPosition:Int)
    {
        DispatchQueue.global().async {
                self.actionSerialQueue.sync {
                        let open = targetPosition > currentPosition ? "1" : "0"
                        let urlString = "http://10.0.1.1\(placeIndex)/\(open)"
                        _ = self.httpClient.sendGet(urlString)
                        let offset = currentPosition > targetPosition ? currentPosition - targetPosition : targetPosition - currentPosition
                        var delay = 140000*(offset)
                        if targetPosition == 0 || targetPosition == 100 {delay = 14_000_000}
                        usleep(useconds_t(delay))
                        _ = self.httpClient.sendGet(urlString)
                    DispatchQueue.main.async(execute: {
                        self.currentPositionObserver[placeIndex].onNext(targetPosition)
                    })
                }
        }
    }
}
