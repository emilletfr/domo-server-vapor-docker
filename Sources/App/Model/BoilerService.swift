//
//  BoilerService.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import RxSwift
import Foundation
import Dispatch

class BoilerService : BoilerServicable, Error
{
    internal var temperaturePublisher = PublishSubject<Double>()
    internal var heaterPublisher = PublishSubject<Bool>()
    internal var pompPublisher = PublishSubject<Bool>()
    
    internal var temperatureObserver = PublishSubject<Double>()
    
    let httpClient : HttpClientable
    
    required init(httpClient:HttpClientable = HttpClient(), refreshPeriod: Int = 60)
    {
        self.httpClient = httpClient
        
        _ = heaterPublisher.subscribe(onNext: { (onOff:Bool) in
            self.activate(heaterOrPomp:true, onOff)
        })
        _ = pompPublisher.subscribe(onNext: { (onOff:Bool) in
            self.activate(heaterOrPomp:false, onOff)
        })
        
        _ = Observable.merge(secondEmitter, Observable.of(0))
            .filter { $0%refreshPeriod == 0 }
            .flatMap { _ -> Observable<ReturnValue> in
                let url = Boiler.temperature.baseUrl(appendPath: "getTemperature")
                return httpClient.send(url:url, responseType: ReturnValue.self) }
            .map({ (r) -> Double in return Double(r.value)})
            .subscribe(self.temperatureObserver)
        
        _ = temperaturePublisher.flatMap({ (temperature: Double) -> Observable<ReturnServoDegres> in
            let url = Boiler.temperature.baseUrl(appendPath: "setTemperature?value=" + String(Int(temperature)))
            return httpClient.send(url:url, responseType: ReturnServoDegres.self)
        }).subscribe()
        
        // { "servoDegres": 57}
        struct ReturnServoDegres : Decodable {
            let servoDegres: Int
        }
    }
    
    func activate(heaterOrPomp:Bool, _ onOff:Bool) {
        let url = Boiler.heaterAndPomp.baseUrl(appendPath: (heaterOrPomp == false ? "1" : "0")  + (onOff == true ? "1" : "0"))
        _ = self.httpClient.send(url: url, responseType: ReturnStatus.self).subscribe()
        
        // [{ "status": 1}]
        struct ReturnStatus : Decodable {
            let status: Int
        }
    }
    
    
}
