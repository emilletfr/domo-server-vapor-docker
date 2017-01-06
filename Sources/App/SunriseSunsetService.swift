//
//  SunriseSunsetManager.swift
//  VaporApp
//
//  Created by Eric on 25/09/2016.
//
//

import Foundation
import Dispatch
import Vapor
import HTTP

protocol SunriseSunsetServiceable
{
    var sunriseTime : String? {get}
    var sunriseTimeDidChange : ((Void) -> Void)? {get}
    var sunsetTime : String? {get}
    var sunsetTimeDidChange : ((Void) -> Void)? {get}
}

class SunriseSunsetService : /*RepeatTimer,*/ SunriseSunsetServiceable
{
    var sunriseTime : String? {didSet{sunriseTimeDidChange?()}}
    var sunsetTime : String? {didSet{sunsetTimeDidChange?()}}
    var sunriseTimeDidChange : ((Void) -> Void)?
    var sunsetTimeDidChange : ((Void) -> Void)?

    private var subscribedIndex = 0
    
    // Can't init is singleton
    private init()
    {
    //    self.startRepeatTimerWithRepeatDelay(delay: 3600)
    }
    
    //MARK: Shared Instance
    static let shared: SunriseSunsetServiceable = SunriseSunsetService()
    

    func repeatTimerFired()
    {
        do
        {
            let urlString = "http://api.sunrise-sunset.org/json?lat=48.556&lng=6.401&date=today&formatted=0"
            let response = try drop.client.get(urlString)
            guard let sunsetDateStr = response.data["results", "sunset"]?.string, let sunriseDateStr = response.data["results", "sunrise"]?.string else
            {
                log("ERROR - SunriseSunsetService:repeatTimerFired:guard:response: \(response)")
                return
            }
            let iso8601DateFormatter = DateFormatter()
            iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
            iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            guard var sunsetDate = iso8601DateFormatter.date(from: sunsetDateStr), let sunriseDate = iso8601DateFormatter.date(from: sunriseDateStr) else
            {
                log("ERROR - SunriseSunsetService:repeatTimerFired:guard:iso8601DateFormatter: \(sunriseDateStr)  \(sunsetDateStr)")
                return
            }
            sunsetDate = sunsetDate.addingTimeInterval(60*00) // +40mn
            let localDateformatter = DateFormatter()
            localDateformatter.timeZone = TimeZone(abbreviation: "CEST") // "CEST": "Europe/Paris"
            localDateformatter.dateFormat = "HH:mm"
            let sunsetTime = localDateformatter.string(from: sunsetDate)
            let sunriseTime = localDateformatter.string(from: sunriseDate)
            self.sunsetTime = sunsetTime
            self.sunriseTime = sunriseTime
        }
        catch {log("ERROR - SunriseSunsetService:repeatTimerFired:catch:error: \(error)")}
    }
}
 
