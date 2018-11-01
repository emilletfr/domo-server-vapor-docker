//
//  OutdoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 20/09/2016.
//
//

import RxSwift

class OutdoorTempService : OutdoorTempServicable
{
    let temperatureObserver  = PublishSubject<Double>()
    let httpClient : HttpClientable
    
    required init(httpClient:HttpClientable = HttpClient(), refreshPeriod: Int = 60*60)
    {
        self.httpClient = httpClient
        
        let url = "http://api.apixu.com/v1/current.json?key=1bd4a03d8e744bc89ff133424161712&q=damelevieres"
        _ = Observable.merge(secondEmitter, Observable.of(0))
            .filter { $0%refreshPeriod == 0 }
            .flatMap { _ in return httpClient.send(url: url, responseType: OutdoorTempResponse.self) }
            .map({ r -> Double in return r.current.temp_c })
            .subscribe(self.temperatureObserver)
    }
}


struct OutdoorTempResponse: Decodable {
    let current: Current
    struct Current: Decodable {
        let temp_c: Double
    }
    
}

/*
{"location":{"name":"Damelevieres","region":"Lorraine","country":"France","lat":48.55,"lon":6.38,"tz_id":"Europe/Paris","localtime_epoch":1541088962,"localtime":"2018-11-01 17:16"},"current":{"last_updated_epoch":1541088021,"last_updated":"2018-11-01 17:00","temp_c":12.0,"temp_f":53.6,"is_day":1,"condition":{"text":"Sunny","icon":"//cdn.apixu.com/weather/64x64/day/113.png","code":1000},"wind_mph":10.5,"wind_kph":16.9,"wind_degree":190,"wind_dir":"S","pressure_mb":1011.0,"pressure_in":30.3,"precip_mm":0.1,"precip_in":0.0,"humidity":71,"cloud":0,"feelslike_c":10.2,"feelslike_f":50.3,"vis_km":10.0,"vis_miles":6.0}}
 */
