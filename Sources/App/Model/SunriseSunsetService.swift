//
//  SunriseSunsetManager.swift
//  VaporApp
//
//  Created by Eric on 25/09/2016.
//
//

import Foundation
import Dispatch
import RxSwift


final class SunriseSunsetService : SunriseSunsetServicable
{
    let sunriseTimeObserver = ReplaySubject<String>.create(bufferSize: 1)
    let sunsetTimeObserver = ReplaySubject<String>.create(bufferSize: 1)
    
    required init(httpClient:HttpClientable = HttpClient(), refreshPeriod: Int = 60*60) {
        // default values
        sunriseTimeObserver.onNext("08:00")
        sunsetTimeObserver.onNext("22:00")
        // fetch api
        let sunriseSunsetObservable = Observable.merge(secondEmitter, Observable.of(0))
            .filter { $0%refreshPeriod == 0 }
            .flatMap { _ in return httpClient.send(url:SunriseSunset.baseUrl(), responseType: SunriseSunset.Response.self) }
            .map({ (r) -> (String, String) in
                let iso8601DateFormatter = DateFormatter()
                iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
                iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                let sunsetDate = iso8601DateFormatter.date(from: r.results.civil_twilight_end)
                let sunriseDate = iso8601DateFormatter.date(from: r.results.sunrise)
                
                let localDateformatter = DateFormatter()
                localDateformatter.timeZone = TimeZone(abbreviation: "CEST") // "CEST": "Europe/Paris"
                localDateformatter.dateFormat = "HH:mm"
                
                let sunset = localDateformatter.string(from: sunsetDate!)
                let sunrise = localDateformatter.string(from: sunriseDate!)
                return (sunrise, sunset)
            })
        
        _ = sunriseSunsetObservable.map { (sunrise, sunset) -> String in
            return sunrise
            }.subscribe(sunriseTimeObserver)
 
        _ = sunriseSunsetObservable.map { (sunrise, sunset) -> String in
            return sunset
            }.subscribe(sunsetTimeObserver)
    }
}


struct SunriseSunset
{
    static func baseUrl() -> String {
        return "http://api.sunrise-sunset.org/json?lat=48.556&lng=6.401&date=today&formatted=0"
    }
    
    struct Response: Decodable
    {
        let results: Results
        let status:String
        
        struct Results: Decodable
        {
            let sunrise: String
            let sunset: String
            let solar_noon: String
            let day_length: Int
            let civil_twilight_begin: String
            let civil_twilight_end: String
            let nautical_twilight_begin: String
            let nautical_twilight_end: String
            let astronomical_twilight_begin: String
            let astronomical_twilight_end: String
        }
    }
}
