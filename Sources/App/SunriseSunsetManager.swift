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

class SunriseSunsetManager
{
    let serialQueue = DispatchQueue(label: "net.emilletfr.domo.SunriseSunsetManager.Internal")
    private var sunriseTimeInternalValue : String?
    var sunriseTime : String? {
        get {return serialQueue.sync { sunriseTimeInternalValue }}
        set (newValue) {serialQueue.sync { sunriseTimeInternalValue = newValue}}
    }
    private var sunsetTimeInternalValue : String?
    var sunsetTime : String? {
        get {return serialQueue.sync { sunsetTimeInternalValue }}
        set (newValue) {serialQueue.sync { sunsetTimeInternalValue = newValue}}
    }
    private var client: ClientProtocol.Type

    
    init(droplet:Droplet)
    {
        self.client = droplet.client
        NotificationCenter.default.addObserver(forName: NSNotification.Name("TimerSeconde"), object: nil, queue: OperationQueue()) { (notification:Notification) in
            print("AAA")
        }
        
        DispatchQueue(label: "net.emilletfr.domo.SunriseSunsetManager.Timer").async
            {
                while true
                {
                    self.retrieveSunriseSunset()
                    sleep(3600)
                }
        }
    }
    


    func retrieveSunriseSunset()
    {
        let urlString = "http://api.sunrise-sunset.org/json?lat=48.556&lng=6.401&date=today&formatted=0"
        
        let response = try? self.client.get(urlString)
        guard let sunriseDateStr = response?.data["results", "sunrise"]?.string else {return}
        guard let sunsetDateStr = response?.data["results", "sunset"]?.string else {return}
        let iso8601DateFormatter = DateFormatter()
        iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
        iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
         guard let sunsetDate = iso8601DateFormatter.date(from: sunsetDateStr), let sunriseDate = iso8601DateFormatter.date(from: sunriseDateStr) else {return}
        let localDateformatter = DateFormatter()
        localDateformatter.timeZone = TimeZone(abbreviation: "CEST") // "CEST": "Europe/Paris"
        localDateformatter.dateFormat = "HH:mm"
        self.sunsetTime = localDateformatter.string(from: sunsetDate)
        self.sunriseTime = localDateformatter.string(from: sunriseDate)
        if let sunrise = self.sunriseTime {print("sunriseTime : \(sunrise)")}
        if let sunset = self.sunsetTime {print("sunsetTime : \(sunset)")}

        
   /*
        URLSession.shared.dataTask(with: url!, completionHandler: { (data:Data?, response:URLResponse?,error: Error?) in
            
            guard let dataResp = data,
                let json = try? JSONSerialization.jsonObject(with: dataResp, options: .mutableContainers),
                let jsonDict = json as? [String:Any],
                let results = jsonDict["results"] as? [String:Any],
                let sunset = results["sunset"],
                let sunrise = results["sunrise"] else {print("----------error"); return}
            
            if #available(OSX 10.12, *)
            {
                let dateFormatter = ISO8601DateFormatter()
                let tz = TimeZone(abbreviation: "CEST") // "CEST": "Europe/Paris"
                dateFormatter.timeZone = tz
                let sunsetDate = dateFormatter.date(from: (sunset as! String))
                let sunriseDate = dateFormatter.date(from: (sunrise as! String))
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                self.sunsetTime = formatter.string(from: sunsetDate!)
                self.sunriseTime = formatter.string(from: sunriseDate!)
                if let sunrise = self.sunriseTime {print("sunriseTime : \(sunrise)")}
                if let sunset = self.sunsetTime {print("sunsetTime : \(sunset)")}
      /*
                let sunsetTimeInterval = sunsetDate?.timeIntervalSinceNow
                if let sunsetTimeInterval = sunsetTimeInterval
                {
                    if sunsetTimeInterval > 0
                    {
                        self.sunsetTimer?.cancel()
                        self.sunsetTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global(qos:.background))
                        self.sunsetTimer?.scheduleOneshot(deadline: DispatchTime.init(secondsFromNow:sunsetTimeInterval))
                        self.sunsetTimer?.setEventHandler(handler: self.sunsetWorkItem)
                        self.sunsetTimer?.resume()
                    }
                }
                
                let sunriseTimeInterval = sunriseDate?.timeIntervalSinceNow
                if let sunriseTimeInterval = sunriseTimeInterval
                {
                    if sunriseTimeInterval > 0
                    {
                        self.sunriseTimer?.cancel()
                        self.sunriseTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global(qos:.background))
                        self.sunriseTimer?.scheduleOneshot(deadline: DispatchTime.init(secondsFromNow:sunriseTimeInterval))
                        self.sunriseTimer?.setEventHandler(handler: self.sunriseWorkItem)
                        self.sunriseTimer?.resume()
                    }
                }
                 */
            }
            else { }
        }).resume()
         */
    }
    /*
    func sunriseWorkItem()
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        print(formatter.string(from: Date(timeIntervalSinceNow: 0 )))
        print(self.sunriseTime)
    }
    
    func sunsetWorkItem ()
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        print(formatter.string(from: Date(timeIntervalSinceNow: 0 )))
        print(self.sunsetTime)
    }
 */
    



}
/*
class ISO8601DateFormatterLinux: DateFormatter {
    
    static let sharedDateFormatter = ISO8601DateFormatterLinux()
    
    override init() {
        super.init()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
    
}
*/





