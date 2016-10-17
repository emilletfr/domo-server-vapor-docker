//
//  IndoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 26/09/2016.
//
//

import Foundation
import Dispatch
import Vapor
import HTTP


class IndoorTempController //: NSObject//, XMLParserDelegate
{
    let serialQueue = DispatchQueue(label: "net.emilletfr.domo.IndoorTempManager")
    private var internalDegresValue : Double = 11.0
    var degresValue : Double {
        get {return serialQueue.sync { internalDegresValue }}
        set (newValue) {serialQueue.sync { internalDegresValue = newValue}}
    }
    private var client: ClientProtocol.Type
    var urlSession : URLSession?
    var repeatTimer: DispatchSourceTimer?
    var urlSessionDataTask : URLSessionDataTask?
    
     init(droplet:Droplet)
    {
        self.client = droplet.client
        
        
        
        /*
        self.repeatTimer?.cancel()
        self.repeatTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global(qos:.background))
        self.repeatTimer?.scheduleRepeating(deadline: DispatchTime.init(secondsFromNow:1), interval: DispatchTimeInterval.seconds(10))
        self.repeatTimer?.setEventHandler(handler: self.retrieveTemp)
        self.repeatTimer?.resume()
 */
    }
    
    
     func retrieveTemp() -> Double
    {
       // self.urlSession?.invalidateAndCancel()
        let sessionConfiguration = URLSessionConfiguration.default
        print(self.urlSession)
        self.urlSession = URLSession(configuration:sessionConfiguration)
        let urlString = "http://78.240.101.103:1080/status.xml"
        print("12:15")
        print("111")
  //      self.urlSessionDataTask?.cancel()
        let semaphore = DispatchSemaphore(value: 1)
        self.urlSessionDataTask = self.urlSession?.dataTask(with: URL(string:urlString)!) { (data:Data?, response:URLResponse?, error:Error?) in
            print("222")
            guard
                let dataResp = data,
                let dataString = String(data: dataResp, encoding: .utf8),
                let startRange = dataString.range(of: "<an1>"),
                let endRange = dataString.range(of: "</an1>")
                else {return}
            
            let start = dataString.index((startRange.lowerBound), offsetBy: 5)
            let end = dataString.index((endRange.lowerBound), offsetBy: 0)
            let temperatureString = dataString[start ..< end]
            guard let temperatureIpx = Double(temperatureString) else {return}
            let temperature =  (temperatureIpx * 0.3223) - 50
            print(temperature)
            
            self.degresValue = temperature
        semaphore.signal()
            
            }
        self.urlSessionDataTask?.resume()
        
        semaphore.wait()
        return(self.degresValue)
    }
    /*
    private func retrieveTemp()
    {
        self.xmlParser?.abortParsing()
        let url = URL(string: "http://78.240.101.103:1080/status.xml")
        URLSession.shared.dataTask(with: url!, completionHandler: { (data:Data?, response:URLResponse?,error: Error?) in
            guard let dataResp = data  else {print(error); return}
  
            let localParser = XMLParser(data: dataResp)
             localParser.delegate = self
            localParser.parse()
            self.xmlParser = localParser
         }).resume()
    }
    
    func parserDidStartDocument(_ parser: XMLParser)
    {
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
    {
        if self.parsed.val == nil {self.parsed.key = elementName}
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if self.parsed.key == "an1" && self.parsed.val == nil {self.parsed.val = string}
    }
    
    func parserDidEndDocument(_ parser: XMLParser)
    {
        guard let stringValue = self.parsed.val, let floatValue = Double(stringValue) else {return}
        self.degresValue = (floatValue * 0.3223) - 50.0
        if let  degres = self.degresValue {print("indoorTemp : \(degres)")}
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
    {
        print(parseError)
    }
*/
}
