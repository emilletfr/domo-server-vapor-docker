//
//  SunriseSunsetManager.swift
//  VaporApp
//
//  Created by Eric on 25/09/2016.
//
//

import Foundation

class SunriseSunsetManager
{
    let serialQueue = DispatchQueue(label: "net.emilletfr.domo.SunriseSunsetManagerInternal")
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
 //   var sunsetTimer : DispatchSourceTimer?
  //  var sunriseTimer : DispatchSourceTimer?
   // var retrieveTimer : DispatchSourceTimer?
    
    init()
    {
    }
/*
    func retrieveSunriseSunset()
    {
        let url = URL(string: "http://api.sunrise-sunset.org/json?lat=48.556&lng=6.401&date=today&formatted=0")
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
            }
            else { }
        }).resume()
    }
    
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






