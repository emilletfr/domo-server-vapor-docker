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
        
        _ = temperaturePublisher.flatMap({ (temperature: Double) -> Observable<Boiler.ServoDegresResponse> in
            let url = Boiler.temperature.baseUrl(appendPath: "setTemperature?value=" + String(Int(temperature)))
            return httpClient.send(url:url, responseType: Boiler.ServoDegresResponse.self)
        }).subscribe()
    }
    
    func activate(heaterOrPomp:Bool, _ onOff:Bool) {
        let url = Boiler.heaterAndPomp.baseUrl(appendPath: (heaterOrPomp == false ? "1" : "0")  + (onOff == true ? "1" : "0"))
        _ = self.httpClient.send(url: url, responseType: Boiler.StatusResponse.self).subscribe()
    }
}


enum Boiler: Int
{
    case heaterAndPomp = 0, temperature, count
    
    func baseUrl(appendPath pathComponent: String = "") -> String {
        let scheme = "http://"
        var base = ""
        switch self {
        case .heaterAndPomp: base = isHomeKitModulesNetworkIpOrDns
            ?  "10.0.1.15:8015" : "boiler-heater-pomp"
        case .temperature: base = isHomeKitModulesNetworkIpOrDns
            ?  "10.0.1.25" : "boiler-temperature"
        case .count: base = ""
        }
        return scheme + base + "/" + pathComponent
    }
    
    // { "servoDegres": 57}
    struct ServoDegresResponse : Decodable {
        let servoDegres: Int
    }
    
    // [{ "status": 1}]
    struct StatusResponse : Decodable {
        let status: Int
    }
}
