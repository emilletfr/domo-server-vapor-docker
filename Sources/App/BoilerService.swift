//
//  BoilerService.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import RxSwift
import Foundation


protocol BoilerServicable
{
    var heaterPublisher : PublishSubject<Bool> {get}
    var pompPublisher : PublishSubject<Bool> {get}
    
    init(httpClient:HttpClientable)
}


class BoilerService : BoilerServicable, Error
{
    internal var heaterPublisher = PublishSubject<Bool>()
    internal var pompPublisher = PublishSubject<Bool>()

    let httpClient : HttpClientable
    
    let actionSerialQueue = DispatchQueue(label: "net.emillet.domo.BoilerService")
    var retryDelay = 0

    required init(httpClient:HttpClientable = HttpClient())
    {
        self.httpClient = httpClient
        
        _ = heaterPublisher.subscribe(onNext: { (onOff:Bool) in
            self.retryDelay = 0
            self.activate(heaterOrPomp:true, onOff)
        })
        
        _ = pompPublisher.subscribe(onNext: { (onOff:Bool) in
            self.retryDelay = 0
            self.activate(heaterOrPomp:false, onOff)
        })
    }
    
    func activate(heaterOrPomp:Bool, _ onOff:Bool)
    {
        DispatchQueue.global().async
            {
                self.actionSerialQueue.sync
                    {
                        sleep(UInt32(self.retryDelay))
                        let url = "http://10.0.1.15:8015/" + (heaterOrPomp == false ? "1" : "0")  + (onOff == true ? "1" : "0")
                        if let response = self.httpClient.sendGet(url), let _ = response.parseToJSONFrom(path:["status"]) {/*print(status)*/}
                        else
                        {
                            self.retryDelay += 1
                            self.activate(heaterOrPomp: heaterOrPomp, onOff)
                        }
                }
        }

    }
}
