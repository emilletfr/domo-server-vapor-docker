//
//  OutdoorTempManager.swift
//  VaporApp
//
//  Created by Eric on 20/09/2016.
//
//

import Vapor
import Foundation
import Dispatch

class OutdoorTempManager// : NSObject
{
    let serialQueue = DispatchQueue(label: "net.emilletfr.domo.OutdoorTempManager")
    private var internalDegresValue : Double?
    var degresValue : Double? {
        get {return serialQueue.sync { internalDegresValue }}
        set (newValue) {serialQueue.sync { internalDegresValue = newValue}}
    }
    var retrieveTimer : DispatchSourceTimer?
    weak var drop :Droplet!
    

    
     init(droplet:Droplet)
    {
        self.drop = droplet
      //  let dplet = self.drop
        let client = self.drop.client
      //  self.init()
        DispatchQueue(label: "init").async {
        
    //    sleep(10)
       
        self.drop = droplet
        let dispatchQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        
        for  index1 in 1...400 {
             sleep(1)
            
            for  index2 in 1...10 {
            dispatchQueue.async {
                
                 do {
                let urlString = "http://api.openweathermap.org/data/2.5/weather?zip=54360,fr&APPID=9c44d7610c061d8c3a7873c51da2e885&units=metric"

                    let resp = try client.request(.get, urlString, headers: ["Connection":"close"], query: ["":""], body: "")
                    
                 
                    
                  //  print(client.getStream(<#T##ClientProtocol#>)
                    
         //           resp.onComplete! = {((_stream:Stream) throws -> Void) in }
                    
             
                   
         //           resp.onComplete! = {(_: (Stream) throws -> Void) in
                        
            //        }.return
               //     var zz : ((Stream) throws -> Void) -> Void
                    
             //       var zz : (Stream)  -> Void = { (stream:Stream)  in
                        
                 //   }
  //            do
                    
                    /*
                    resp.onComplete! =   {(stream:Stream) throws -> Void  in
                    //    print(stream)
                    //    try? stream.close()
                    }
 */
// let zz = resp.onComplete
                    
             //       sleep(5)
                    
       //         print(rr)

                
                    let sessionId = self.drop.sessions.makeIdentifier()
                    self.drop.sessions.destroy(sessionId)
                    
                    
                    print("\(index1)-\(index2)")
                //    self.degresValue = response.data["main", "temp"]?.double ?? nil
                //  if let temp = self.degresValue {print("outdoorTemp : \(temp)")}
                } catch {
                    print(error)
                }

                }
             }
            }
        }
    }
    
    private func retrieveTemp()
    {
        DispatchQueue(label: "queuename1", attributes: .concurrent).async
            {
                do {
                
                    let urlString = "http://api.openweathermap.org/data/2.5/weather?zip=54360,fr&APPID=9c44d7610c061d8c3a7873c51da2e885&units=metric"
                    let response = try Droplet().client.get(urlString)
                //    self.degresValue = response.data["main", "temp"]?.double ?? nil
                  //  if let temp = self.degresValue {print("outdoorTemp : \(temp)")}
                } catch {
                    print(error)
                }
        }
    }
}

