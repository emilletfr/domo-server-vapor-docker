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

protocol SunriseSunsetServicable
{
    var sunriseTimeObserver : PublishSubject<String> {get}
    var sunsetTimeObserver : PublishSubject<String> {get}
    init(httpClient:HttpClientable, repeatTimer: RepeatTimer)
}

final class SunriseSunsetService : SunriseSunsetServicable
{
    let sunriseTimeObserver = PublishSubject<String>()
    let sunsetTimeObserver = PublishSubject<String>()
    
    let httpClient : HttpClientable
    let autoRepeatTimer : RepeatTimer
    
    required init(httpClient:HttpClientable = HttpClient(), repeatTimer: RepeatTimer = RepeatTimer(delay:60*60))
    {
        self.httpClient = httpClient
        self.autoRepeatTimer = repeatTimer
        repeatTimer.didFireBlock = { [weak self] in
            guard let response = httpClient.sendGet("http://api.sunrise-sunset.org/json?lat=48.556&lng=6.401&date=today&formatted=0") else {return}
            guard let sunsetDateStr = response.parseToStringFrom(path: ["results", "civil_twilight_end"]), let sunriseDateStr =  response.parseToStringFrom(path: ["results", "sunrise"]) else
            {
                //     self?.sunriseTimeObserver.onError(self!)
                //    self?.sunsetTimeObserver.onError(self!)
                return
            }
            let iso8601DateFormatter = DateFormatter()
            iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
            iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            guard let sunsetDate = iso8601DateFormatter.date(from: sunsetDateStr), let sunriseDate = iso8601DateFormatter.date(from: sunriseDateStr) else
            {
                print("ERROR - SunriseSunsetService:repeatTimerFired:guard:iso8601DateFormatter: \(sunriseDateStr)  \(sunsetDateStr)")
                //    self?.sunriseTimeObserver.onError(self!)
                //   self?.sunsetTimeObserver.onError(self!)
                return
            }
            let localDateformatter = DateFormatter()
            localDateformatter.timeZone = TimeZone(abbreviation: "CEST") // "CEST": "Europe/Paris"
            localDateformatter.dateFormat = "HH:mm"
            self?.sunriseTimeObserver.onNext(localDateformatter.string(from: sunriseDate))
            self?.sunsetTimeObserver.onNext(localDateformatter.string(from: sunsetDate))
        }
    }
}

