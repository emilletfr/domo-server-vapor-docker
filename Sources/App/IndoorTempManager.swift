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

class IndoorTempManager //: NSObject//, XMLParserDelegate
{
    let serialQueue = DispatchQueue(label: "net.emilletfr.domo.IndoorTempManager")
    private var internalDegresValue : Double?
    var degresValue : Double? {
        get {return serialQueue.sync { internalDegresValue }}
        set (newValue) {serialQueue.sync { internalDegresValue = newValue}}
    }
    private var client: ClientProtocol.Type

    
     init(droplet:Droplet)
    {
        self.client = droplet.client
        /*
        DispatchQueue(label: "net.emilletfr.domo.IndoorTempManager.Timer").async
            {
                while true
                {
                    self.retrieveTemp()
                    sleep(3600)
                }
        }
*/
     }
    
    
    private func retrieveTemp()
    {
        let urlString = "http://10.0.1.200/status.xml"
        let response = try? self.client.get(urlString)
        guard (response?.data) != nil else {return}
        
     //   let resp = try? self.client.
      //  print(resp)
        print(String(describing: response?.data))
        
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
