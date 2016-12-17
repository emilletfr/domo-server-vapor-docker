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

class SunriseSunsetService : RepeatTimer
{
 //   var sunriseTime : String?
  //  var sunsetTime : String?

    var completion : ((_ sunriseTime:String?, _ sunsetTime:String?) -> Void)?

    init(completion : ((_ sunriseTime:String?,_ sunsetTime:String?) -> Void)?)
    {
        self.completion = completion
            self.startRepeatTimerWithRepeatDelay(delay: 3600)
    }

    func repeatTimerFired()
    {
      //  log("SunriseSunsetController:retrieveSunriseSunset")
        let urlString = "http://api.sunrise-sunset.org/json?lat=48.556&lng=6.401&date=today&formatted=0"
        let response = try? drop.client.get(urlString)
   //     guard let sunriseDateStr = response?.data["results", "sunrise"]?.string else {return}
        guard let sunsetDateStr = response?.data["results", "sunset"]?.string, let sunriseDateStr = response?.data["results", "sunrise"]?.string else {self.completion?(nil,nil); return}
        let iso8601DateFormatter = DateFormatter()
        iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
        iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard var sunsetDate = iso8601DateFormatter.date(from: sunsetDateStr), let sunriseDate = iso8601DateFormatter.date(from: sunriseDateStr) else {self.completion?(nil,nil);return}
        sunsetDate = sunsetDate.addingTimeInterval(60*00) // +40mn
        let localDateformatter = DateFormatter()
        localDateformatter.timeZone = TimeZone(abbreviation: "CEST") // "CEST": "Europe/Paris"
        localDateformatter.dateFormat = "HH:mm"
        let sunsetTime = localDateformatter.string(from: sunsetDate)
        let sunriseTime = localDateformatter.string(from: sunriseDate)
     //   if let sunrise = self.sunriseTime {log("sunriseTime : \(sunrise)")}
      //  if let sunset = self.sunsetTime {log("sunsetTime : \(sunset)")}
        self.completion?(sunriseTime, sunsetTime)

    }

}
 
